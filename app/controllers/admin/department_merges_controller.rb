module Admin
  class DepartmentMergesController < MergesController
    protected

    def resource_class
      Department
    end

    def move_events!
      @source.events.find_each { |e| e.update!(department: @target) }
    end
  end
end
