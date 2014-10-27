class EventTime < ActiveRecord::Base
  belongs_to :event

  validates :starting, :ending, presence: true

  def start_date
    starting.strftime("%m-%d-%Y")
  end

  def start_time
    starting.strftime("%I:%M %p")
  end

  def end_date
    ending.strftime("%m-%d-%Y")
  end

  def end_time
    ending.strftime("%I:%M %p")
  end

end