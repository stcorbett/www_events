class Event < ActiveRecord::Base

  belongs_to :user
  has_many :event_times

  after_initialize :define_lakes_of_fire_access_methods

  attr_accessor :current_event_time

  validates :hosting_location, :main_contact_person, :contact_person_email,
            :event_recurrence, :event_description, :user, :title,
            presence: true

  validates_length_of :event_description, :minimum => 0, :maximum => 1000
  validates_length_of :event_description, :minimum => 0, :maximum => 50, 
                      :tokenizer => lambda { |str| str.scan(/\w+/) },
                      :too_long  => "must have at most %{count} words"

  validate :has_event_time

  def self.sorted_by_date(specific_date=nil)
    event_times = EventTime.joins(:event).order("event_times.starting ASC, events.hosting_location ASC")
    if specific_date
      start_of_day = Time.zone.local(specific_date.year, specific_date.month, specific_date.day)
      end_of_day = Time.zone.local(specific_date.year, specific_date.month, specific_date.day + 1)
      event_times = event_times.where("event_times.starting > ? AND event_times.starting < ?", start_of_day, end_of_day)
    end

    event_times.collect do |event_time| 
      event = event_time.event
      event.current_event_time = event_time
      event
    end
  end

  def self.lakes_of_fire_event_hash
    {
        "Wednesday" =>  sorted_by_date(Date.new(2015,6,17)).
                        collect{|event| event.lakes_of_fire_hash},
        "Thursday" =>   sorted_by_date(Date.new(2015,6,18)).
                        collect{|event| event.lakes_of_fire_hash},
        "Friday" =>     sorted_by_date(Date.new(2015,6,19)).
                        collect{|event| event.lakes_of_fire_hash},
        "Saturday" =>   sorted_by_date(Date.new(2015,6,20)).
                        collect{|event| event.lakes_of_fire_hash},
        "Sunday" =>     sorted_by_date(Date.new(2015,6,21)).
                        collect{|event| event.lakes_of_fire_hash},
    }
  end


  def define_lakes_of_fire_access_methods
    ["single_occurrence", "wednesday", "thursday", "friday", "saturday", "sunday"].each do |event_time_period|
      ["start_date", "start_time", "end_date", "end_time"].each do |event_time_type|
        self.define_singleton_method("#{event_time_period}_#{event_time_type}".to_sym) do
          event_time_finder(event_time_period, event_time_type)
        end
      end
    end
  end

  def has_event_time
    if event_times.empty?
      errors.add(:event_times, "are needed")
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

  def event_time_finder(event_time_period, event_time_type)
    return nil unless self.event_times.present?

    event_time = case event_time_period
                      when "single_occurrence"
                        event_times.first
                      when "wednesday"
                        event_times.find{|event_time| event_time.starting > Time.zone.local(2015,6,17) && event_time.ending < Time.zone.local(2015,6,18) }
                      when "thursday"
                        event_times.find{|event_time| event_time.starting > Time.zone.local(2015,6,18) && event_time.ending < Time.zone.local(2015,6,19) }
                      when "friday"
                        event_times.find{|event_time| event_time.starting > Time.zone.local(2015,6,19) && event_time.ending < Time.zone.local(2015,6,20) }
                      when "saturday"
                        event_times.find{|event_time| event_time.starting > Time.zone.local(2015,6,20) && event_time.ending < Time.zone.local(2015,6,21) }
                      when "sunday"
                        event_times.find{|event_time| event_time.starting > Time.zone.local(2015,6,21) && event_time.ending < Time.zone.local(2015,6,22) }
                      else
                        nil
                      end

    begin
      event_time && event_time.send(event_time_type)
    rescue NoMethodError
      nil
    end
  end

  def lakes_of_fire_hash
    {
      "Title" => title,
      "Location" => hosting_location,
      "StartTime" => current_event_time.starting.in_time_zone,
      "EndTime" => current_event_time.ending.in_time_zone,
      "Time" => current_event_time.starting.in_time_zone.strftime("%l:%M %p"),
      "Duration" => current_event_time.duration_human,
      "Description" => event_description
    }
  end

  def event_time_error_messages
    event_times.collect do |event_time|
      event_time.errors.full_messages
    end.flatten
  end

end