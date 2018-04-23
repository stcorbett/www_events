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

  def event_icons(event)
    if event.categories.any?
      display = "<span class='icons'>"
      event.categories.each do |category|
        display << event_icon(category) if event.send(category)
      end
      display << "</span>"
    else
      ""
    end
  end

  def event_icon(name)
    %(<img src="/fonts/#{name}.svg"> )
  end

  def event_categories(event)
    event.categories.collect do |category|
      event_cateogry_icon(category)
    end.join
  end

  def event_cateogry_icon(name)
    %(<div class="category">) +
      %(<img src="/fonts/#{name}.svg"> ) +
      name.to_s.humanize +
    "</div>"
  end

end
