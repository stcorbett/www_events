module Admin
  class LocationMergesController < MergesController
    protected

    def resource_class
      Location
    end

    # See CampMergesController#move_events! for rationale on update_all.
    def move_events!
      @source.events.update_all(location_id: @target.id, updated_at: Time.zone.now)
    end
  end
end
