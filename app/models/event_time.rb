class EventTime < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :event

  validates :starting, :ending, presence: true

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

end