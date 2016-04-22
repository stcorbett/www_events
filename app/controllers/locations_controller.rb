class LocationsController < ApplicationController
  before_filter :require_admin, only: :update

  def index
    @locations = Location.all
  end

  def update
    @location = Location.new(*location_params)

    Event.transaction do
      @location.events.each do |event|
        event.update_attributes!(event_params)
      end
    end

    redirect_to locations_path, notice: "Location Updated"
  rescue => e
    redirect_to locations_path, flash: {error: "Error Updating Location" }
  end

  def location_params
    hosting_location = params[:location][:original_hosting_location]
    site_id = params[:location][:original_site_id]

    hosting_location = nil if hosting_location.blank?
    site_id = nil if site_id.blank?

    [hosting_location, site_id]
  end

  def event_params
    {
      hosting_location: params[:location][:hosting_location],
      site_id: params[:location][:site_id]
    }.delete_if { |k, v| v.blank? }
  end

end