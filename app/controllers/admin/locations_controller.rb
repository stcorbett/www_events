module Admin
  class LocationsController < ApplicationController
    before_action :require_admin
    before_action :set_location, only: [:show, :edit, :update, :destroy]

    # GET /admin/locations
    def index
      locations = Location.includes(:camp, :events).order(name: :asc)
      @active_locations, @archived_locations = locations.partition { |l| !l.archived }
      @form_location = Location.new
    end

    def bulk_edit
      @bulk_location_rows = build_bulk_location_rows
    end

    def bulk_update
      location_archive_params = bulk_archive_params(:locations)

      ActiveRecord::Base.transaction do
        update_bulk_locations(location_archive_params)
        update_bulk_camps(bulk_archive_params(:camps))
        update_bulk_departments(bulk_archive_params(:departments))
      end

      redirect_to admin_locations_path, notice: bulk_update_notice(location_archive_params.keys)
    rescue ActiveRecord::RecordInvalid => e
      redirect_to bulk_edit_admin_locations_path, alert: "Error updating locations: #{e.record.errors.full_messages.to_sentence}"
    end

    def show
      @location = Location.find(params[:id])

      direct = @location.events.ordered_by_first_event_time.includes(:event_times)
      @current_events, @past_events = direct.partition(&:in_configured_year?)

      if @location.camp.present?
        camp_events = @location.camp.events.ordered_by_first_event_time.includes(:event_times)
        @current_camp_events, @past_camp_events = camp_events.partition(&:in_configured_year?)
      end
    end

    # GET /admin/locations/:id/edit
    def edit
      # Locations attached to a camp are edited via the camp's edit page.
      if @location.camp.present?
        redirect_to edit_admin_camp_path(@location.camp)
        return
      end

      events = @location.events.ordered_by_first_event_time.includes(:event_times)
      @current_events, @past_events = events.partition(&:in_configured_year?)
    end

    # POST /admin/locations
    def create
      @location = Location.new(location_params)
      if @location.save
        redirect_to admin_locations_path, notice: 'Location was successfully created.'
      else
        locations = Location.includes(:camp, :events).order(name: :asc)
        @active_locations, @archived_locations = locations.partition { |l| !l.archived }
        @form_location = @location
        flash.now[:alert] = 'Error creating location.'
        render :index
      end
    end

    # PATCH/PUT /admin/locations/1
    def update
      if @location.update(location_params)
        redirect_to admin_locations_path, notice: 'Location was successfully updated.'
      else
        events = @location.events.includes(:event_times).order(title: :asc)
        @current_events, @past_events = events.partition(&:in_configured_year?)
        flash.now[:alert] = 'Error updating location.'
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /admin/locations/1
    def destroy
      if @location.destroy
        redirect_to admin_locations_path, notice: 'Location was successfully destroyed.'
      else
        locations = Location.includes(:camp, :events).order(name: :asc)
        @active_locations, @archived_locations = locations.partition { |l| !l.archived }
        @form_location = Location.new
        flash.now[:alert] = @location.errors.full_messages.join(", ")
        render :index
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_location
        @location = Location.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      # Modify this to reflect the actual attributes of your Location model
      def location_params
        params.require(:location).permit(:name, :precision, :camp_site_identifier, :lat, :lng, :archived)
      end

      def build_bulk_location_rows
        rows = Location.includes(:camp, :departments).map do |location|
          camp = location.camp
          departments = location.departments.to_a

          {
            key: "location:#{location.id}",
            type: "location",
            param_scope: "locations",
            record_id: location.id,
            dom_id: "bulk_location_location_#{location.id}",
            display_name: bulk_location_display_name(location, camp, departments),
            attached_record_summary: bulk_attached_record_summary(camp, departments),
            details: bulk_location_details(location, camp, departments),
            archived: location.archived? || camp&.archived? || departments.any?(&:archived?),
            location_id: location.id,
            camp_id: camp&.id,
            department_ids: departments.map(&:id)
          }
        end

        rows.concat(
          Camp.where(location_id: nil).order(:name).map do |camp|
            {
              key: "camp:#{camp.id}",
              type: "camp",
              param_scope: "camps",
              record_id: camp.id,
              dom_id: "bulk_location_camp_#{camp.id}",
              display_name: "Camp #{camp.name}",
              attached_record_summary: nil,
              details: "camp without location | year #{camp.year}",
              archived: camp.archived?,
              location_id: nil,
              camp_id: camp.id,
              department_ids: []
            }
          end
        )

        rows.concat(
          Department.where(location_id: nil).order(:name).map do |department|
            {
              key: "department:#{department.id}",
              type: "department",
              param_scope: "departments",
              record_id: department.id,
              dom_id: "bulk_location_department_#{department.id}",
              display_name: "Department #{department.name}",
              attached_record_summary: nil,
              details: "department without location",
              archived: department.archived?,
              location_id: nil,
              camp_id: nil,
              department_ids: [department.id]
            }
          end
        )

        attach_bulk_event_counts(rows)
        rows.sort_by { |row| [row[:display_name].to_s.downcase, row[:type], row[:record_id]] }
      end

      def bulk_location_display_name(location, camp, departments)
        return location.name if location.name.present?
        return "Site #{location.camp_site_identifier}" if location.camp_site_identifier.present?

        "Location ##{location.id}"
      end

      def bulk_attached_record_summary(camp, departments)
        attached_records = []
        attached_records << "camp: #{camp.name}" if camp.present?
        attached_records << "departments: #{departments.map(&:name).to_sentence}" if departments.any?
        attached_records.join(" | ").presence
      end

      def bulk_location_details(location, camp, departments)
        details = ["location ##{location.id}", location.precision]
        details << "site: #{location.camp_site_identifier}" if location.camp_site_identifier.present?
        details.compact.join(" | ")
      end

      def attach_bulk_event_counts(rows)
        counts = Hash.new { |hash, key| hash[key] = { current: 0, previous: 0 } }
        location_row_keys = {}
        camp_row_keys = {}
        department_row_keys = {}

        rows.each do |row|
          location_row_keys[row[:location_id]] = row[:key] if row[:location_id].present?
          camp_row_keys[row[:camp_id]] = row[:key] if row[:camp_id].present?
          row[:department_ids].each { |department_id| department_row_keys[department_id] = row[:key] }
        end

        event_conditions = []
        event_binds = {}

        if location_row_keys.any?
          event_conditions << "events.location_id IN (:location_ids)"
          event_binds[:location_ids] = location_row_keys.keys
        end

        if camp_row_keys.any?
          event_conditions << "(events.camp_id IN (:camp_ids) OR events.hosting_camp_id IN (:camp_ids))"
          event_binds[:camp_ids] = camp_row_keys.keys
        end

        if department_row_keys.any?
          event_conditions << "events.department_id IN (:department_ids)"
          event_binds[:department_ids] = department_row_keys.keys
        end

        if event_conditions.any?
          Event.where(event_conditions.join(" OR "), event_binds).pluck(:id, :created_at, :location_id, :camp_id, :hosting_camp_id, :department_id).each do |_id, created_at, location_id, camp_id, hosting_camp_id, department_id|
            row_keys = [
              location_row_keys[location_id],
              camp_row_keys[camp_id],
              camp_row_keys[hosting_camp_id],
              department_row_keys[department_id]
            ].compact.uniq

            count_key = created_at > Event.configured_year_cutoff ? :current : :previous
            row_keys.each { |row_key| counts[row_key][count_key] += 1 }
          end
        end

        rows.each do |row|
          row[:current_events_count] = counts[row[:key]][:current]
          row[:previous_events_count] = counts[row[:key]][:previous]
        end
      end

      def bulk_archive_params(scope)
        raw_params = params[scope]
        raw_params.respond_to?(:to_unsafe_h) ? raw_params.to_unsafe_h : {}
      end

      def update_bulk_locations(location_archive_params)
        location_ids = location_archive_params.keys.map(&:to_i)

        Location.includes(:camp, :departments).where(id: location_ids).find_each do |location|
          archived = bulk_archived_value(location_archive_params[location.id.to_s])

          location.update!(archived: archived)
          location.camp&.update!(archived: archived)
          location.departments.each { |department| department.update!(archived: archived) }
        end
      end

      def update_bulk_camps(camp_archive_params)
        camp_ids = camp_archive_params.keys.map(&:to_i)

        Camp.includes(:location).where(id: camp_ids).find_each do |camp|
          archived = bulk_archived_value(camp_archive_params[camp.id.to_s])

          camp.update!(archived: archived)
          camp.location&.update!(archived: archived)
        end
      end

      def update_bulk_departments(department_archive_params)
        department_ids = department_archive_params.keys.map(&:to_i)

        Department.includes(:location).where(id: department_ids).find_each do |department|
          archived = bulk_archived_value(department_archive_params[department.id.to_s])

          department.update!(archived: archived)
          department.location&.update!(archived: archived)
        end
      end

      def bulk_archived_value(attributes)
        ActiveModel::Type::Boolean.new.cast(attributes.fetch("archived", "0"))
      end

      def bulk_update_notice(location_ids)
        scoped_locations = Location.where(id: location_ids.map(&:to_i))
        archived_count = scoped_locations.where(archived: true).count
        visible_count = scoped_locations.where(archived: false).count

        "#{archived_count} locations archived, #{visible_count} visible"
      end
  end
end
