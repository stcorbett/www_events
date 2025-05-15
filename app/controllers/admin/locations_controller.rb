module Admin
  class LocationsController < ApplicationController
    before_action :require_admin
    before_action :set_location, only: [:update, :destroy]

    # GET /admin/locations
    def index
      @locations = Location.all.order(name: :asc)
      @form_location = Location.new
    end

    # POST /admin/locations
    def create
      @location = Location.new(location_params)
      if @location.save
        redirect_to admin_locations_path, notice: 'Location was successfully created.'
      else
        @locations = Location.all.order(name: :asc)
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
        @locations = Location.all.order(name: :asc)
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
        @locations = Location.all.order(name: :asc)
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
        params.require(:location).permit(:name, :precision, :camp_site_identifier, :lat, :lng)
      end
  end
end 