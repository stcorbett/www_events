module Admin
  class CampsController < ApplicationController
    before_action :require_admin
    before_action :set_camp, only: [:show, :update, :destroy]

    def index
      @camps = Camp.all.order(name: :asc)
      @form_camp = Camp.new
    end

    def show
      @events = @camp.events.includes(:event_times).order(title: :asc)
    end

    def create
      @camp = Camp.new(camp_params)
      if @camp.save
        redirect_to admin_camps_path, notice: 'Camp was successfully created.'
      else
        @camps = Camp.all.order(name: :asc)
        @form_camp = @camp
        flash.now[:alert] = 'Error creating camp.'
        render :index
      end
    end

    def update
      if @camp.update(camp_params)
        redirect_to admin_camps_path, notice: 'Camp was successfully updated.'
      else
        @camps = Camp.all.order(name: :asc)
        @form_camp = @camp # This @camp has errors
        flash.now[:alert] = 'Error updating camp.'
        render :index
      end
    end

    def destroy
      # Note: Add before_destroy callback in Camp model if deletion needs to be conditional
      if @camp.destroy
        redirect_to admin_camps_path, notice: 'Camp was successfully destroyed.'
      else
        @camps = Camp.all.order(name: :asc)
        @form_camp = Camp.new 
        flash.now[:alert] = @camp.errors.full_messages.join(", ") || "Could not destroy camp."
        render :index
      end
    end

    private

    def set_camp
      @camp = Camp.find(params[:id])
    end

    def camp_params
      params.require(:camp).permit(:name, :description)
    end
  end
end 