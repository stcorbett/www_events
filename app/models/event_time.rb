class EventTime < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :event

  validates :starting, :ending, presence: true
  validate  :lakes_of_fire_start_time_validation, :lakes_of_fire_end_time_validation

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
    starting.strftime("%l:%M %p")
  end

  def end_date
    ending.strftime("%m-%d-%Y")
  end

  def end_time
    ending.strftime("%l:%M %p")
  end

  def duration_human
    distance_of_time_in_words(starting - ending).gsub("about ", "")
  end

private
  def before_lakes_of_fire?(time)
    time < LakesOfFireConfig.start_time
  end

  def after_lakes_of_fire?(time)
    LakesOfFireConfig.end_time < time
  end

end