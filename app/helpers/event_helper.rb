module EventHelper
  def event_is_editable?(event, user)
    (user_owns_event(event, user) && submissions_are_open) || user.admin
  end

  def user_owns_event(event, user)
    user.editable_events.include?(event)
  end

  def lakes_of_fire_date(day_of_week)
    LakesOfFireConfig.event_days[day_of_week.downcase.to_sym]
  end

  def days_of_week_select_options
    LakesOfFireConfig.event_days.collect do |day, date|
      [date.strftime("%a - %-m/%-d"), date.strftime("%A")]
    end
  end

end
