module Admin
  class LocationMergesController < MergesController
    protected

    def resource_class
      Location
    end

    def move_events!
      @source.events.find_each { |e| e.update!(location: @target) }
    end
  end
end
