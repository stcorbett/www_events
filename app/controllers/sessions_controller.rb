class SessionsController < ApplicationController
  skip_before_filter :require_login, only: [:new, :create]

  def new
  end

  def create
    user = User.create_or_authorize(env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path
  end

  def omniauth_params
    params.require(:user).permit
  end
end