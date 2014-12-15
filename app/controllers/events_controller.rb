class EventsController < ApplicationController

  def index
    respond_to do |format|
      format.html { redirect_to(new_event_path()) }
      format.xml  { @events_hash = Event.lakes_of_fire_event_hash; render layout: false }
    end
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new(main_contact_person: current_user.name, contact_person_email: current_user.email)
    @events = Event.sorted_by_date
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to new_event_path(), :notice => "Event added"
    else
      @events = Event.sorted_by_date
      render :new
    end
  end

  def edit
    @event = current_user.editable_events.find(params[:id])
  end

  def update
    @event = current_user.editable_events.find(params[:id])

    if @event.update(event_params)
      redirect_to @event, :notice => "Event updated"
    else
      render :edit
    end
  end

  def destroy
    @event = current_user.editable_events.find(params[:id])
    @event.destroy
    redirect_to root_path
  end

private

  def event_params
    permitted = params.require(:event).permit(:hosting_location, :main_contact_person, :contact_person_email, :event_recurrence, :event_description)

    if params[:event][:event_recurrence] == "single"
      permitted["event_times"] = [single_occurrence_event_time]
    elsif params[:event][:event_recurrence] == "multiple"
      permitted["event_times"] = multiple_event_times
    end

    permitted["user_id"] = current_user.id

    permitted
  end


  def single_occurrence_event_time
    event = params[:event]
    starting, ending = start_and_end_from_inputs( event[:single_occurrence_start_date], 
                                                  event[:single_occurrence_start_time],
                                                  event[:single_occurrence_end_date],
                                                  event[:single_occurrence_end_time])

    EventTime.new(starting: starting, ending: ending )
  end

  def multiple_event_times
    %w(wednesday thursday friday saturday sunday).collect do |day_name|
      start_and_end_for_day(day_name)
    end.compact
  end

  def start_and_end_for_day(day_name)
    event = params[:event]

    return nil unless [event["#{day_name}_start_time"].present?, event["#{day_name}_end_time"].present?].any?

    inputs = [event["#{day_name}_start_date"], 
              event["#{day_name}_start_time"],
              event["#{day_name}_end_date"],
              event["#{day_name}_end_time"]]

    return nil if inputs.empty?

    starting, ending = start_and_end_from_inputs(*inputs)

    EventTime.new(starting: starting, ending: ending )
  end

  def start_and_end_from_inputs(start_date_param, start_time_param, end_date_param, end_time_param)
    start_date = Date.strptime(start_date_param, '%m-%d-%Y')
    start_time = start_time_param.empty? ? Time.new(0) : Time.parse(start_time_param)
    start_date_time = Time.zone.local(start_date.year, start_date.month, start_date.day, start_time.hour, start_time.min)

    end_date = Date.strptime(end_date_param, '%m-%d-%Y')
    end_time = end_time_param.empty? ? Time.new(0) : Time.parse(end_time_param)
    end_date_time = Time.zone.local(end_date.year, end_date.month, end_date.day, end_time.hour, end_time.min)

    [start_date_time, end_date_time]
  end

end