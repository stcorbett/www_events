module Admin
  # Abstract parent for the three merge controllers (camps, locations, departments).
  # Subclasses only need to provide `resource_class` and `move_events!`. Everything
  # else — actions, view lookup (via Rails' parent _prefixes fallback), and path
  # helpers — is shared.
  class MergesController < ApplicationController
    before_action :require_admin
    before_action :find_source
    before_action :ensure_source_mergeable
    before_action :find_target, except: [:new]

    # GET /admin/<resource>/:id/merge
    def new
      if params[:target_id].present?
        redirect_to merge_path_for(:confirm, target_id: params[:target_id])
        return
      end
      load_source_events
      @candidate_options = candidate_targets.map { |r| candidate_option(r) }
    end

    # GET /admin/<resource>/:id/merge/:target_id/confirm
    def confirm
      load_source_events
      load_target_events
    end

    # POST /admin/<resource>/:id/merge/:target_id
    def execute
      ActiveRecord::Base.transaction do
        move_events!
      end
      redirect_to merge_path_for(:result), notice: "Events moved from #{display_label(@source)} to #{display_label(@target)}."
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
      flash[:error] = "Merge failed: #{e.message}. No events were moved."
      redirect_to merge_path_for(:confirm)
    end

    # GET /admin/<resource>/:id/merge/:target_id/result
    def result
      load_source_events
      load_target_events
    end

    # PATCH /admin/<resource>/:id/merge/:target_id/archive
    def archive_source
      @source.update!(archived: true)
      redirect_to show_source_url, notice: "Archived #{display_label(@source)}."
    end

    # DELETE /admin/<resource>/:id/merge/:target_id/delete
    def delete_source
      if @source.destroy
        redirect_to show_target_url, notice: "Deleted #{display_label(@source)}. Its events now live on #{display_label(@target)}."
      else
        flash[:error] = "Could not delete: #{@source.errors.full_messages.join(', ')}"
        redirect_to merge_path_for(:result)
      end
    end

    protected

    # --- Subclass extension points ---
    def resource_class
      raise NotImplementedError, "#{self.class} must define #resource_class"
    end

    # Subclasses implement the actual event-FK reassignment.
    def move_events!
      raise NotImplementedError, "#{self.class} must define #move_events!"
    end

    # --- Shared helpers ---
    def resource_singular
      resource_class.name.underscore
    end
    helper_method :resource_singular

    def resource_label
      resource_class.name
    end
    helper_method :resource_label

    def find_source
      @source = resource_class.find(params[:id])
    end

    # Skip merge entry/flow entirely if the source record has merge-blocking
    # state (e.g. a Location with attached camps/departments). The check is a
    # no-op for records whose model has no `validate ..., on: :merge` rules.
    # The result/archive/delete actions run after the merge already happened —
    # they need to remain reachable, so we skip the gate there.
    def ensure_source_mergeable
      return if %w[result archive_source delete_source].include?(action_name)
      return if @source.valid?(:merge)

      flash[:error] = "Cannot merge #{display_label(@source)}: #{@source.errors.full_messages.join('; ')}"
      redirect_to edit_source_url
    end

    def find_target
      @target = resource_class.not_archived.find(params[:target_id])
    end

    def candidate_targets
      resource_class.not_archived
                    .where.not(id: @source.id)
                    .includes(:events)
                    .order(:name)
    end

    def candidate_option(record)
      events  = record.events
      current = events.count(&:in_configured_year?)
      past    = events.size - current
      ["#{record.name} (id=#{record.id}) — current: #{current}, past: #{past}", record.id]
    end

    def load_source_events
      events = @source.events.includes(:event_times).order(title: :asc)
      @source_current_events, @source_past_events = events.partition(&:in_configured_year?)
    end

    def load_target_events
      events = @target.events.includes(:event_times).order(title: :asc)
      @target_current_events, @target_past_events = events.partition(&:in_configured_year?)
    end

    def display_label(record)
      "#{record.name} (id=#{record.id})"
    end
    helper_method :display_label

    # --- URL helpers, built dynamically from resource_singular ---
    def merge_path_for(action, target_id: @target&.id)
      helper = "merge_#{action == :new ? '' : "#{action}_"}admin_#{resource_singular}_path".sub('merge__', 'merge_')
      args = target_id ? [@source, { target_id: target_id }] : [@source]
      send(helper, *args)
    end
    helper_method :merge_path_for

    def merge_archive_url
      send("merge_archive_admin_#{resource_singular}_path", @source, target_id: @target.id)
    end
    helper_method :merge_archive_url

    def merge_delete_url
      send("merge_delete_admin_#{resource_singular}_path", @source, target_id: @target.id)
    end
    helper_method :merge_delete_url

    def edit_source_url
      send("edit_admin_#{resource_singular}_path", @source)
    end
    helper_method :edit_source_url

    def show_source_url
      send("admin_#{resource_singular}_path", @source)
    end
    helper_method :show_source_url

    def show_target_url
      send("admin_#{resource_singular}_path", @target)
    end
    helper_method :show_target_url
  end
end
