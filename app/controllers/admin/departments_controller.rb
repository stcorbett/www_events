module Admin
  class DepartmentsController < ApplicationController
    before_action :require_admin
    before_action :set_department, only: [:update, :destroy]

    def index
      @departments = Department.all.order(name: :asc)
      @form_department = Department.new
    end

    def create
      @department = Department.new(department_params)
      if @department.save
        redirect_to admin_departments_path, notice: 'Department was successfully created.'
      else
        @departments = Department.all.order(name: :asc)
        @form_department = @department
        flash.now[:alert] = 'Error creating department.'
        render :index
      end
    end

    def update
      if @department.update(department_params)
        redirect_to admin_departments_path, notice: 'Department was successfully updated.'
      else
        @departments = Department.all.order(name: :asc)
        @form_department = @department # This @department has errors
        flash.now[:alert] = 'Error updating department.'
        render :index
      end
    end

    def destroy
      # Note: Add before_destroy callback in Department model if deletion needs to be conditional
      # (e.g., if department has associated events or users)
      if @department.destroy
        redirect_to admin_departments_path, notice: 'Department was successfully destroyed.'
      else
        @departments = Department.all.order(name: :asc)
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
      params.require(:department).permit(:name) # Only name is editable for now
    end
  end
end 