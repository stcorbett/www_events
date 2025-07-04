module Admin
  class CampsController < ApplicationController
    before_action :require_admin
    before_action :set_camp, only: [:show, :edit, :update, :destroy]

    def index
      @camps = Camp.includes(:location, events: :event_times).order(name: :asc)
      @form_camp = Camp.new
    end

    def show
      @events = @camp.events.includes(:event_times).order(title: :asc)
    end

    def edit
      @camp.build_location unless @camp.location
      @events = @camp.events.includes(:event_times).order(title: :asc)
    end

    def create
      @camp = Camp.new(camp_params)
      if @camp.save
        redirect_to admin_camps_path, notice: 'Camp was successfully created.'
      else
        @camps = Camp.includes(:location, events: :event_times).order(name: :asc)
        @form_camp = @camp
        flash.now[:alert] = 'Error creating camp.'
        render :index
      end
    end

    def update
      if @camp.update(camp_params)
        redirect_to admin_camp_path(@camp), notice: 'Camp was successfully updated.'
      else
        @events = @camp.events.includes(:event_times).order(title: :asc)
        flash.now[:alert] = 'Error updating camp.'
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      # Note: Add before_destroy callback in Camp model if deletion needs to be conditional
      if @camp.destroy
        redirect_to admin_camps_path, notice: 'Camp was successfully destroyed.'
      else
        @camps = Camp.includes(:location, events: :event_times).order(name: :asc)
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
      p = params.require(:camp).permit(:name, :description, location_attributes: [:id, :lat, :lng, :camp_site_identifier, :name, :precision])
      if p[:location_attributes].present?
        p[:location_attributes].merge!(name: nil, precision: 'specific')
      end
      p
    end
  end
end 