class SessionsController < ApplicationController
  def create
    user = User.create_or_authorize(env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end

  def omniauth_params
    params.require(:user).permit
  end
end