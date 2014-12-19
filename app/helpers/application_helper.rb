module ApplicationHelper

  def admin_badge(user)
    if user.admin
      "<span class='badge label-success'>admin</span>"
    end
  end

end
