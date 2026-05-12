module Admin
  class DepartmentsController < ApplicationController
    before_action :require_admin
    before_action :set_department, only: [:show, :edit, :update, :destroy]

    def index
      departments = Department.includes(:events).order(name: :asc)
      @active_departments, @archived_departments = departments.partition { |d| !d.archived }
      @form_department = Department.new
    end

    def show
      events = @department.events.ordered_by_first_event_time.includes(:event_times)
      @current_events, @past_events = events.partition(&:in_configured_year?)
    end

    def edit
      events = @department.events.ordered_by_first_event_time.includes(:event_times)
      @current_events, @past_events = events.partition(&:in_configured_year?)
    end

    def create
      @department = Department.new(department_params)
      if @department.save
        redirect_to admin_departments_path, notice: 'Department was successfully created.'
      else
        departments = Department.includes(:events).order(name: :asc)
      @active_departments, @archived_departments = departments.partition { |d| !d.archived }
        @form_department = @department
        flash.now[:alert] = 'Error creating department.'
        render :index
      end
    end

    def update
      if @department.update(department_params)
        redirect_to admin_departments_path, notice: 'Department was successfully updated.'
      else
        events = @department.events.includes(:event_times).order(title: :asc)
        @current_events, @past_events = events.partition(&:in_configured_year?)
        flash.now[:alert] = 'Error updating department.'
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      # Note: Add before_destroy callback in Department model if deletion needs to be conditional
      # (e.g., if department has associated events or users)
      if @department.destroy
        redirect_to admin_departments_path, notice: 'Department was successfully destroyed.'
      else
        departments = Department.includes(:events).order(name: :asc)
      @active_departments, @archived_departments = departments.partition { |d| !d.archived }
        @form_department = Department.new 
        flash.now[:alert] = @department.errors.full_messages.join(", ") || "Could not destroy department."
        render :index
      end
    end

    private

    def set_department
      @department = Department.find(params[:id])
    end

    def department_params
      params.require(:department).permit(:name, :archived)
    end
  end
end 