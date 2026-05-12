module Admin
  class LocationsController < ApplicationController
    before_action :require_admin
    before_action :set_location, only: [:show, :update, :destroy]

    # GET /admin/locations
    def index
      locations = Location.includes(:camp, :events).order(name: :asc)
      @active_locations, @archived_locations = locations.partition { |l| !l.archived }
      @form_location = Location.new
    end

    def show
      @location = Location.includes(:events, camp: { events: :event_times }).find(params[:id])

      direct_events = @location.events.sort_by { |e| e.title.to_s }
      @current_events, @past_events = direct_events.partition(&:in_configured_year?)

      if @location.camp.present?
        camp_events = @location.camp.events.sort_by { |e| e.title.to_s }
        @current_camp_events, @past_camp_events = camp_events.partition(&:in_configured_year?)
      end
    end

    # POST /admin/locations
    def create
      @location = Location.new(location_params)
      if @location.save
        redirect_to admin_locations_path, notice: 'Location was successfully created.'
      else
        locations = Location.includes(:camp, :events).order(name: :asc)
        @active_locations, @archived_locations = locations.partition { |l| !l.archived }
        @form_location = @location
        flash.now[:alert] = 'Error creating location.'
        render :index
      end
    end

    # PATCH/PUT /admin/locations/1
    def update
      if @location.update(location_params)
        redirect_to admin_locations_path, notice: 'Location was successfully updated.'
      else
        locations = Location.includes(:camp, :events).order(name: :asc)
        @active_locations, @archived_locations = locations.partition { |l| !l.archived }
        @form_location = @location
        flash.now[:alert] = 'Error updating location.'
        render :index
      end
    end

    # DELETE /admin/locations/1
    def destroy
      if @location.destroy
        redirect_to admin_locations_path, notice: 'Location was successfully destroyed.'
      else
        locations = Location.includes(:camp, :events).order(name: :asc)
        @active_locations, @archived_locations = locations.partition { |l| !l.archived }
        @form_location = Location.new
        flash.now[:alert] = @location.errors.full_messages.join(", ")
        render :index
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_location
        @location = Location.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      # Modify this to reflect the actual attributes of your Location model
      def location_params
        params.require(:location).permit(:name, :precision, :camp_site_identifier, :lat, :lng, :archived)
      end
  end
end 