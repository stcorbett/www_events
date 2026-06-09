module Admin
  class CampsController < ApplicationController
    before_action :require_admin
    before_action :set_camp, only: [:show, :edit, :update, :destroy]

    def index
      load_index_camps
      @form_camp = Camp.new
    end

    def show
      events = @camp.events.ordered_by_first_event_time.includes(:event_times)
      @current_events, @past_events = events.partition(&:in_configured_year?)
    end

    def edit
      @camp.build_location unless @camp.location
      events = @camp.events.ordered_by_first_event_time.includes(:event_times)
      @current_events, @past_events = events.partition(&:in_configured_year?)
    end

    def create
      @camp = Camp.new(camp_params)
      if @camp.save
        redirect_to admin_camps_path, notice: 'Camp was successfully created.'
      else
        load_index_camps
        @form_camp = @camp
        flash.now[:alert] = 'Error creating camp.'
        render :index
      end
    end

    def update
      if @camp.update(camp_params)
        redirect_to admin_camp_path(@camp), notice: 'Camp was successfully updated.'
      else
        events = @camp.events.includes(:event_times).order(title: :asc)
        @current_events, @past_events = events.partition(&:in_configured_year?)
        flash.now[:alert] = 'Error updating camp.'
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      # Note: Add before_destroy callback in Camp model if deletion needs to be conditional
      if @camp.destroy
        redirect_to admin_camps_path(year: @camp.year), notice: 'Camp was successfully destroyed.'
      else
        load_index_camps(@camp.year)
        @form_camp = Camp.new
        flash.now[:alert] = @camp.errors.full_messages.join(", ") || "Could not destroy camp."
        render :index
      end
    end

    private

    def set_camp
      @camp = Camp.find(params[:id])
    end

    def load_index_camps(selected_year = params[:year].presence)
      @current_year = LakesOfFireConfig.year
      @camp_years = Camp.distinct.order(year: :desc).pluck(:year)
      @previous_camp_years = @camp_years.reject { |year| year == @current_year }
      @selected_year = selected_year.to_s.to_i.nonzero? || @current_year

      unless @selected_year == @current_year || @camp_years.include?(@selected_year)
        @selected_year = @current_year
      end

      camps = Camp.for_year(@selected_year).includes(:location, events: :event_times).order(name: :asc)
      @active_camps, @archived_camps = camps.partition { |camp| !camp.archived }
    end

    def camp_params
      p = params.require(:camp).permit(:name, :description, :archived, location_attributes: [:id, :lat, :lng, :camp_site_identifier, :name, :precision])
      if p[:location_attributes].present?
        p[:location_attributes].merge!(name: nil, precision: 'specific')
      end
      p
    end
  end
end
