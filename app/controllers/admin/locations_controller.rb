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
  end
end 