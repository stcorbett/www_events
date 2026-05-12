module Admin
  class CampMergesController < MergesController
    protected

    def resource_class
      Camp
    end

    # Camps participate in events via TWO foreign keys: camp_id (where the event
    # takes place) and hosting_camp_id (who is running it). Move both.
    def move_events!
      @source.events.find_each       { |e| e.update!(camp: @target) }
      @source.hosted_events.find_each { |e| e.update!(hosting_camp: @target) }
    end
  end
end
