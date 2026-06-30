module Superadmin
  class EventsController < ApplicationController
    before_action :require_superadmin

    def index
      @events = Event
        .includes(:user, :camp, :hosting_camp, :department, :event_times, location: :camps)
        .order(created_at: :desc, title: :asc)
    end
  end
end
