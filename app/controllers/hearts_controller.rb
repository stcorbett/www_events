class HeartsController < ApplicationController

  before_filter :find_event

  def create
    user = current_user

    unless user.heart_for?(@event_time)
      user.with_lock do
        user.add_heart(@event_time)
        user.save!

        @event.heart_count += 1
        @event.save!
      end
    end

    render text: "hearted"
  end

  def destroy
    user = current_user

    if user.heart_for?(@event_time)
      user.with_lock do
        user.remove_heart(@event_time)
        user.save!

        @event.heart_count -= 1
        @event.save!
      end
    end

    render text: "unhearted"
  end

  def find_event
    @event_time = EventTime.find params[:id]
    @event = @event_time.event
  end
end
