module Admin
  class UsersController < ApplicationController
    before_action :require_admin
    before_action :set_user, only: [:show, :update, :edit]

    def index
      cutoff = ActiveRecord::Base.connection.quote(Event.configured_year_cutoff)
      @users = User.left_joins(:events).group(:id).select(
        'users.*',
        'COUNT(events.id) AS events_count',
        "COUNT(events.id) FILTER (WHERE events.created_at > #{cutoff}) AS current_year_events_count"
      ).order(:name)
    end

    def show
      events = @user.events.includes(:event_times).order(title: :asc)
      @current_events, @past_events = events.partition(&:in_configured_year?)
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: 'User was successfully updated.'
      else
        @users = User.all.order(:name)
        flash.now[:alert] = 'Error updating user.'
        render :index
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:admin)
    end
  end
end
