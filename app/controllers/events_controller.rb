class EventsController < ApplicationController

  def index
    redirect_to new_event_path()
  end

  def new
    @event = Event.new
    @events = Event.all
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to new_event_path(), :notice => "Event added"
    else
      @events = Event.all
      render :new
    end
  end

private

  def event_params
    permitted = params.require(:event).permit(:hosting_location, :main_contact_person, :contact_person_email, :event_recurrence, :event_description,
                                              :single_occurrence_start_date, :single_occurrence_start_time, 
                                              :single_occurrence_end_date, :single_occurrence_end_time)

    permitted.merge!(blank_attributes_for_event_time)

    if params[:event][:event_recurrence] == "single"
      permitted.merge!(single_occurrence_event_time)
    elsif params[:event][:event_recurrence] == "multiple"
      permitted.merge!(multiple_occurrence_event_times)
    end

    permitted
  end

  def blank_attributes_for_event_time
    {
      "single_occurrence_start" => nil, "single_occurrence_duration_minutes" => nil,
      "wednesday_start" => nil, "thursday_start" => nil, "friday_start" => nil, "saturday_start" => nil, "sunday_start" => nil,
      "wednesday_duration" => nil, "thursday_duration" => nil, "friday_duration" => nil, "saturday_duration" => nil, "sunday_duration" => nil
    }
  end

  def single_occurrence_event_time
    event = params[:event]
    single_occurrence_start, single_occurrence_duration_minutes = time_and_duration_from_inputs(event[:single_occurrence_start_date], 
                                                                                                event[:single_occurrence_start_time],
                                                                                                event[:single_occurrence_end_date],
                                                                                                event[:single_occurrence_end_time])

    {"single_occurrence_start" => single_occurrence_start, "single_occurrence_duration_minutes" => single_occurrence_duration_minutes}
  end

  def multiple_occurrence_event_times
    {}
  end

  def time_and_duration_from_inputs(start_date_param, start_time_param, end_date_param, end_time_param)
    start_date = Date.parse(start_date_param)
    start_time = Time.parse(start_time_param)
    start_date_time = DateTime.new(start_date.year, start_date.month, start_date.day, start_time.hour, start_time.min)

    end_date = Date.parse(end_date_param)
    end_time = Time.parse(end_time_param)
    end_date_time = DateTime.new(end_date.year, end_date.month, end_date.day, end_time.hour, end_time.min)

    [start_date_time, (end_date_time - start_date_time) * 24 * 60]
  end

end