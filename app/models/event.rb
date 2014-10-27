class Event < ActiveRecord::Base

  has_many :event_times

  def self.sorted_by_date
    all.joins(:event_times).order("event_times.starting ASC").select("events.*, event_times.starting AS starting")
  end

  after_initialize do
    ["single_occurrence", "wednesday", "thursday", "friday", "saturday", "sunday"].each do |event_time_period|
      ["start_date", "start_time", "end_date", "end_time"].each do |event_time_type|
        self.define_singleton_method("#{event_time_period}_#{event_time_type}".to_sym) do
          event_time_finder(event_time_period, event_time_type)
        end
      end
    end
  end

  def event_time_finder(event_time_period, event_time_type)
    # how do values pass back to the form on validation errors

    return nil unless self.event_times.present?
    return nil if self.event_times.size > 1 && event_time_period == "single_occurrence"
    return nil if self.event_times.size == 1 && event_time_period != "single_occurrence"

    event = case event_time_period
            when "single_occurrence"
              event_times.first
            when "wednesday"
              event_times.where("start_time > ?", Date.new(2015,6,17)).where("start_time < ?", Date.new(2015,6,18)).first
            when "thursday"
              event_times.where("start_time > ?", Date.new(2015,6,18)).where("start_time < ?", Date.new(2015,6,19)).first
            when "friday"
              event_times.where("start_time > ?", Date.new(2015,6,19)).where("start_time < ?", Date.new(2015,6,20)).first
            when "saturday"
              event_times.where("start_time > ?", Date.new(2015,6,20)).where("start_time < ?", Date.new(2015,6,21)).first
            when "sunday"
              event_times.where("start_time > ?", Date.new(2015,6,21)).where("start_time < ?", Date.new(2015,6,22)).first
            else
              nil
            end

    begin
      event && event.send(event_time_type)
    rescue NoMethodError
      nil
    end
  end

end