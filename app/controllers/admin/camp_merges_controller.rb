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
  end
end
