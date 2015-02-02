module EventHelper

  def event_is_editable?(event, user)
    user.editable_events.include?(event) || user.admin
  end

  def lakes_of_fire_date(day_of_week)
    LakesOfFireConfig.event_days[day_of_week.downcase.to_sym]
  end

  def days_of_week_select_options
    LakesOfFireConfig.event_days.collect do |day, date|
      [date.strftime("%A - %-m/%-d"), date.strftime("%A")]
    end
  end

end