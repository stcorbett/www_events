class Location

  attr_reader :hosting_location, :site_id

  def self.all
    location_names = Event.uniq.order("hosting_location ASC").pluck(:hosting_location, :site_id)

    location_names.collect do |name, site_id|
      Location.new(name, site_id)
    end
  end

  def initialize(hosting_location, site_id)
    @hosting_location = hosting_location
    @site_id = site_id
  end

  def events
    @events ||= Event.where(hosting_location: hosting_location, site_id: site_id).order("title ASC")
  end

  def human_location
    events.first.human_location
  end
end