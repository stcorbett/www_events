module ApplicationHelper

  def admin_badge(user)
    if user.admin
      "<span class='badge label-success'>admin</span>"
    end
  end

  def event_requirements_start_time
    start_time = LakesOfFireConfig.start_time
    start_time.strftime("%l%p on %B #{ start_time.day.ordinalize }")
  end

  def event_requirements_end_time
    end_time = LakesOfFireConfig.end_time
    end_time.strftime("%l%p on %B #{ end_time.day.ordinalize }")
  end

end
