module Admin
  class DepartmentMergesController < MergesController
    protected

    def resource_class
      Department
    end

    # See CampMergesController#move_events! for rationale on update_all.
    def move_events!
      @source.events.update_all(department_id: @target.id, updated_at: Time.zone.now)
    end
  end
end
