class Location

  attr_reader :hosting_location, :site_id

  def self.all
    location_names = Event.configured_year.order("hosting_location ASC").pluck(:hosting_location, :site_id).uniq

    location_names.collect do |name, site_id|
      Location.new(name, site_id)
    end
  end

  def self.all_locations
    Event.configured_year.order(:hosting_location).uniq.pluck(:hosting_location)
  end

  def initialize(hosting_location, site_id)
    @hosting_location = hosting_location
    @site_id = site_id
  end

  def update_event_attributes(event_params)
    raise "can't update events without hosting_location" unless event_params.keys.include?(:hosting_location)
    raise "can't update events without site_id" unless event_params.keys.include?(:site_id)

    Event.transaction do
      events.each do |event|
        event.update!(event_params)
      end

      @hosting_location = event_params[:hosting_location]
    end
  end

  def events
    @events ||= Event.configured_year.where(hosting_location: hosting_location, site_id: site_id).order("title ASC")
  end

  def human_location
    events.first.human_location
  end

  def hex_tag
    Digest::SHA1.hexdigest hosting_location
  end
end
