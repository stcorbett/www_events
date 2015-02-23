class EventTime < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :event

  validates :starting, :ending, presence: true
  validate  :lakes_of_fire_start_time_validation, :lakes_of_fire_end_time_validation

  def self.start_and_end_from_inputs(day_of_week, start_time, end_time)
    date = LakesOfFireConfig.event_days[day_of_week.downcase.to_sym]
    start_time, end_time = Time.parse(start_time), Time.parse(end_time)

    starting =  Time.zone.local(date.year, date.month, date.day, start_time.hour, start_time.min)
    ending =    Time.zone.local(date.year, date.month, date.day, end_time.hour,   end_time.min)

    ending = ending + 1.day if starting >= ending

    [starting, ending]
  end

  def lakes_of_fire_start_time_validation
    errors.add(:starting, "Can't start before Lakes of Fire Starts!") if before_lakes_of_fire?(starting)
    errors.add(:ending, "Can't end before Lakes of Fire Starts!") if before_lakes_of_fire?(ending)
  end

  def lakes_of_fire_end_time_validation
    errors.add(:starting, "Can't start after Lakes of Fire Ends!") if after_lakes_of_fire?(starting)
    errors.add(:ending, "Can't end after Lakes of Fire Ends!") if after_lakes_of_fire?(ending)
  end

  def start_date
    starting.strftime("%m-%d-%Y")
  end

  def start_time
    return nil unless starting
    starting.strftime("%l:%M%p")
  end

  def end_date
    ending.strftime("%m-%d-%Y")
  end

  def end_time
    return nil unless ending
    ending.strftime("%l:%M%p")
  end

  def duration_human
    distance_of_time_in_words(starting - ending).gsub("about ", "")
  end

  def day_of_event_index
    LakesOfFireConfig.event_days.keys.index(day_of_week.downcase.to_sym)
  end

private
  def before_lakes_of_fire?(time)
    time < LakesOfFireConfig.start_time
  end

  def after_lakes_of_fire?(time)
    LakesOfFireConfig.end_time < time
  end

end