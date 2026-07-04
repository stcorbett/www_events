module Admin
  class CampMergesController < MergesController
    protected

    def resource_class
      Camp
    end

    # Camps participate in events via TWO foreign keys: camp_id (where the event
    # takes place) and hosting_camp_id (who is running it). Move both.
    #
    # Uses update_all (raw SQL UPDATE) rather than update! because we're only
    # changing the FK — running full event validations would re-validate
    # unrelated columns (e.g. event_times from prior years) and fail the merge
    # for reasons unrelated to the move itself. DB-level FK constraints still
    # protect against pointing at a non-existent camp.
    def move_events!
      now = Time.zone.now
      @source.events.update_all(camp_id: @target.id, updated_at: now)
      @source.hosted_events.update_all(hosting_camp_id: @target.id, updated_at: now)
    end

    def load_source_events
      source_events = camp_associated_events(@source).to_a
      @source_current_events, @source_past_events = source_events.partition(&:in_configured_year?)
      @source_hosted_elsewhere_events = source_events.select do |event|
        event.hosting_camp_id == @source.id && event.camp_id != @source.id
      end
    end

    def load_target_events
      target_events = camp_associated_events(@target).to_a
      @target_current_events, @target_past_events = target_events.partition(&:in_configured_year?)
    end

    def camp_associated_events(camp)
      Event.where(camp_id: camp.id)
           .or(Event.where(hosting_camp_id: camp.id))
           .ordered_by_first_event_time
           .includes(:event_times, :camp, :hosting_camp, :location, :department)
    end
  end
end
