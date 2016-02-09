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

  def event_categories(event)
    display = ""
    display << event_icon(:fire_art) if event.fire_art
    display << event_icon(:red_light) if event.red_light
    display << event_icon(:alcohol) if event.alcohol
    display.html_safe
  end

  def event_icon(name)
    %(<div class="category">) +
      %(<img src="/fonts/#{name}.svg"> ) +
      name.to_s.humanize +
    "</div>"
  end

end