class Event < ActiveRecord::Base

  attr_accessor :wednesday_start_date, :wednesday_start_time, :wednesday_end_time, :wednesday_end_date,
                :thursday_start_date, :thursday_start_time, :thursday_end_time, :thursday_end_date,
                :friday_start_date, :friday_start_time, :friday_end_time, :friday_end_date,
                :saturday_start_date, :saturday_start_time, :saturday_end_time, :saturday_end_date,
                :sunday_start_date, :sunday_start_time, :sunday_end_time, :sunday_end_date

  def self.sorted_by_date
    
  end

  def single_occurrence_start_date
    return nil unless single_occurrence_start
    single_occurrence_start.strftime("%m-%d-%Y")
  end

  def single_occurrence_start_time
    return nil unless single_occurrence_start
    single_occurrence_start.strftime("%I:%M %p")
  end

  def single_occurrence_end
    (single_occurrence_start + single_occurrence_duration_minutes * 60)
  end

  def single_occurrence_end_date
    return nil unless single_occurrence_start
    single_occurrence_end.strftime("%m-%d-%Y")
  end

  def single_occurrence_end_time
    return nil unless single_occurrence_start
    single_occurrence_end.strftime("%I:%M %p")
  end

end