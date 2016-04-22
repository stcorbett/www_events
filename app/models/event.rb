class Event < ActiveRecord::Base

  belongs_to :user
  has_many :event_times
  has_one :single_event_time
  accepts_nested_attributes_for :event_times, :single_event_time

  validates_associated :event_times

  attr_accessor :current_event_time

  validates :hosting_location, :main_contact_person, :contact_person_email,
            :event_recurrence, :event_description, :user, :title,
            presence: true

  validates_length_of :event_description, :minimum => 0, :maximum => 1000
  validates_length_of :event_description, :minimum => 0, :maximum => 100, 
                      :tokenizer => lambda { |str| str.scan(/\w+/) },
                      :too_long  => "must have at most %{count} words"

  validate :has_event_time

  def self.sorted_by_date(specific_date=nil)
    event_times = EventTime.joins(:event).
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

  def categories
    ([] <<
        (fire_art ? :fire_art : nil) <<
        (alcohol ? :alcohol : nil) <<
        (red_light ? :red_light : nil)
    ).compact
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

  def lakes_of_fire_hash
    {
      "Title" => title,
      "Location" => hosting_location,
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
      "HumanLocation" => human_location,
      "HumanTime" => current_event_time.human_time
    }
  end

  def human_location
    if site_id.present?
      "#{hosting_location} | Site #{site_id}"
    else
      "#{hosting_location}"
    end
  end

  def event_time_error_messages
    event_times.collect do |event_time|
      event_time.errors.full_messages
    end.flatten
  end

end