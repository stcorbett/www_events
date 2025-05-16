class Event < ActiveRecord::Base

  belongs_to :user
  belongs_to :camp, optional: true
  belongs_to :location, optional: true
  belongs_to :department, optional: true
  belongs_to :hosting_camp, class_name: 'Camp', optional: true
  has_many :event_times, dependent: :destroy
  has_one :single_event_time
  accepts_nested_attributes_for :event_times, :single_event_time

  validates_associated :event_times

  attr_accessor :current_event_time, :where_camp, :where_camp_id, :where_location, :where_imprecise, :who_camp, :who_department

  validates :main_contact_person, :contact_person_email,
            :event_recurrence, :event_description, :user, :title,
            presence: true

  validates_length_of :event_description, :minimum => 0, :maximum => 20000

  validate :has_event_time

  scope :configured_year, -> { where("events.created_at > ?", Date.new(LakesOfFireConfig.year,1,1)) }

  def self.sorted_by_date(specific_date=nil)
    event_times = EventTime.configured_year.joins(:event).
                            order("event_times.starting ASC, event_times.all_day ASC, events.title ASC")
    if specific_date
      start_of_day = Time.zone.local(specific_date.year, specific_date.month, specific_date.day)
      end_of_day = Time.zone.local(specific_date.year, specific_date.month, specific_date.day + 1)
      event_times = event_times.where("event_times.starting >= ? AND event_times.starting < ?", start_of_day, end_of_day)
    end

    event_times.collect do |event_time|
      event = event_time.event
      event.current_event_time = event_time
      event
    end
  end

  def self.lakes_of_fire_event_hash
    {
        "Wednesday" =>  sorted_by_date( LakesOfFireConfig.event_days[:wednesday] ).
                        collect{|event| event.lakes_of_fire_hash},
        "Thursday" =>   sorted_by_date( LakesOfFireConfig.event_days[:thursday] ).
                        collect{|event| event.lakes_of_fire_hash},
        "Friday" =>     sorted_by_date( LakesOfFireConfig.event_days[:friday] ).
                        collect{|event| event.lakes_of_fire_hash},
        "Saturday" =>   sorted_by_date( LakesOfFireConfig.event_days[:saturday] ).
                        collect{|event| event.lakes_of_fire_hash},
        "Sunday" =>     sorted_by_date( LakesOfFireConfig.event_days[:sunday] ).
                        collect{|event| event.lakes_of_fire_hash},
    }
  end

  def self.category_emojis
    {
      fire_art: '🔥',
      alcohol: '🍻',
      red_light: '🔴',
      spectacle: '👓',
      food: '🍽',
      crafting: '🎨',
      sober: '⚖️',
    }
  end

  def categories
    [:fire_art, :alcohol, :red_light, :spectacle, :food, :crafting, :sober].select do |sym|
      send(sym)
    end
  end

  def has_event_time
    if event_times.empty?
      errors.add(:event_times, "are needed")
    end
  end

  def single_event_time
    [event_times.first]
  end

  def build_empty_event_times
    LakesOfFireConfig.event_day_names.each do |day|
      event_times.build(day_of_week: day) unless event_times.find{|time| time.day_of_week.downcase == day.downcase}
    end
  end

  def event_description=(description)
    description = description.gsub("“", "\"")
    description = description.gsub("”", "\"")
    description = description.gsub("−", "-") # minus sign
    description = description.gsub("–", "-") # en-dash
    description = description.gsub("—", "-") # em-dash

    write_attribute(:event_description, description)
  end

  def site_id=(string)
    string = nil if string.blank?
    write_attribute(:site_id, string)
  end

  def where_object
    return camp if camp.present?
    return location if location.present?
  end

  def where
    return 'camp' if camp.present?
    return 'location' if location.present? && location.precision == 'specific'
    return 'multiple_locations' if location.present? && location.precision == 'broad'
  end

  def where_camp
    return camp.name if camp.present?
  end

  def where_camp_id
    return camp.id if camp.present?
  end

  def where_camp_id=(id_string)
    if id_string.to_i == 0
      write_attribute(:camp_id, nil)
    else
      write_attribute(:camp_id, id_string.to_i)
    end
  end

  def where_camp=(camp_name)
    return if camp_id.present?
    return if camp_name.blank?

    self.build_camp(name: camp_name)
  end
  
  def where_location
    return location.name if location.present?
  end
  
  def where_location_id
    return location.id if location.present?
  end
  
  def where_location_id=(id_string)
    if id_string.to_i == 0
      write_attribute(:location_id, nil)
    else
      write_attribute(:location_id, id_string.to_i)
    end
  end
  
  def where_location=(location_name)
    return if location_id.present?
    return if location_name.blank?

    self.build_location(name: location_name, precision: 'specific')
  end
  
  def where_imprecise
    return location.name if location.present? && location.precision == 'broad'
  end
  
  def where_imprecise_id
    return location.id if location.present? && location.precision == 'broad'
  end
  
  def where_imprecise_id=(id_string)
    if id_string.to_i == 0
      # Only clear if we have a broad precision location
      if location && location.precision == 'broad'
        write_attribute(:location_id, nil)
      end
    else
      write_attribute(:location_id, id_string.to_i)
    end
  end
  
  def where_imprecise=(location_name)
    return if location.present?
    return if location_name.blank?
    
    self.build_location(name: location_name, precision: 'broad')
  end

  def lakes_of_fire_hash
    {
      "Title" => title,
      "Location" => "hosting_location",
      "SiteId" => site_id,
      "StartTime" => current_event_time.starting.in_time_zone,
      "EndTime" => current_event_time.ending.in_time_zone,
      "Time" => current_event_time.starting.in_time_zone.strftime("%l:%M %p"),
      "Duration" => current_event_time.duration_human,
      "AllDay" => current_event_time.all_day,
      "Description" => event_description,
      "FireArt" => !!fire_art,
      "Alcohol" => !!alcohol,
      "Explicit" => !!red_light,
      "Food" => !!food,
      "Craft" => !!crafting,
      "Sober" => !!sober,
      "Spectacle" => !!spectacle,
      "HumanLocation" => human_location,
      "HumanTime" => current_event_time.human_time
    }
  end

  def human_location
    return 'unknown' unless where_object.present?

    where_object_name = case where_object
    when Camp
      "#{where_object.name} (camp)"
    when Location
      "#{where_object.name}"
    else
      ''
    end

    if site_id.present?
      "#{where_object_name} | Site #{site_id}"
    else
      where_object_name
    end
  end

  def event_time_error_messages
    event_times.collect do |event_time|
      event_time.errors.full_messages
    end.flatten
  end

  def category_emojis
    self.class.category_emojis.slice(*categories)
  end

end
