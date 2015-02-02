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
    @event = Event.new(new_event_attributes)
    @events = Event.sorted_by_date
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to new_event_path(), :notice => "Event added"
    else
      @events = Event.sorted_by_date
      @event.event_times = lakes_of_fire_blank_event_times(@event.event_times)["event_times"]
      render :new
    end
  end

  def edit
    @event = find_editable_event
  end

  def update
    @event = find_editable_event

    if @event.update(event_params)
      redirect_to @event, :notice => "Event updated"
    else
      @event.event_times = lakes_of_fire_blank_event_times(@event.event_times)["event_times"]
      render :edit
    end
  end

  def destroy
    @event = current_user.editable_events.find(params[:id])
    @event.destroy
    redirect_to root_path
  end

private

  # new
  def new_event_attributes
    attributes = {}
    attributes.merge! contact_person_attributes
    attributes.merge! lakes_of_fire_blank_event_times
    attributes
  end

  def contact_person_attributes
    {main_contact_person: current_user.name, contact_person_email: current_user.email}
  end

  def lakes_of_fire_blank_event_times(existing_events=[])
    event_times = []
    LakesOfFireConfig.event_day_names.each do |day|
      if existing_event = existing_events.find{|event| event.day_of_week.downcase == day.downcase}
        event_times << existing_event
      else
        event_times << EventTime.new(day_of_week: day)
      end
    end

    {"event_times" => event_times}
  end

  # edit/update
  def find_editable_event
    if current_user.admin
      Event.find(params[:id])
    else
      current_user.editable_events.find(params[:id])
    end
  end

  # create/update
  def event_params
    permitted = params.require(:event).permit(:hosting_location, :main_contact_person, :contact_person_email, 
                                              :event_recurrence, :event_description, :title)

    if params[:event][:event_recurrence] == "single"
      permitted["event_times"] = single_event_time
    elsif params[:event][:event_recurrence] == "multiple"
      permitted["event_times"] = multiple_event_times
    end

    permitted["user_id"] = current_user.id

    permitted
  end

  # process event times inputs
  def single_event_time
    [
      event_time_from(params["event"][:single_event_time_attributes]["0"])
    ].compact
  end

  def multiple_event_times
    events = []
    raw_event_input = params["event"][:event_times_attributes].values
    raw_event_input.each do |raw_event_time|
      events << event_time_from(raw_event_time)
    end

    events.compact
  end

  def event_time_from(raw_event_input)
    return nil unless raw_event_input[:starting].present? && 
                      raw_event_input[:ending].present? && 
                      raw_event_input[:day_of_week].present?

    starting, ending = EventTime.start_and_end_from_inputs( raw_event_input[:day_of_week], 
                                                            raw_event_input[:starting],
                                                            raw_event_input[:ending])

    EventTime.new(starting: starting, ending: ending, day_of_week: raw_event_input[:day_of_week] )
  end

end