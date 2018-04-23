class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :require_login

  helper_method :current_user, :admin_logged_in?, :submissions_are_open

  def require_login
    if !logged_in?
      session[:return_to_url] = request.url if request.get?
      redirect_to login_path
    end
  end

  def logged_in?
    !!current_user
  end

  def current_user
    User.find_by(id: session[:user_id])
  end

  def require_admin
    if !admin_logged_in?
      redirect_to login_path
    end
  end

  def admin_logged_in?
    !!current_user.admin
  end

  def submissions_are_open
    Time.zone.now < LakesOfFireConfig.event_submissions_close_at
  end
end
