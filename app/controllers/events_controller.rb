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
    if submissions_are_open || current_user.admin
      @event = Event.new(new_event_attributes)
      @event.build_empty_event_times
    end
    @events = Event.configured_year.sorted_by_date
  end

  def create
    @event = Event.new(event_params)

    if @event.save && (submissions_are_open || current_user.admin)
      redirect_to new_event_path(new_event: @event.id), :notice => "Event added"
    else
      @events = Event.configured_year.sorted_by_date
      @event.build_empty_event_times
      render :new
    end
  end

  def edit
    @event = find_editable_event
    @event.build_empty_event_times
  end

  def update
    @event = find_editable_event
    set_event_attributes_for_update!(@event, event_params)

    if @event.save
      redirect_to @event, :notice => "Event updated"
    else
      @event.build_empty_event_times
      render :edit
    end
  end

  def destroy
    @event = find_editable_event
    @event.destroy
    redirect_to root_path, :notice => "Event removed"
  end

private

  # new
  def new_event_attributes
    attributes = {}
    attributes.merge! contact_person_attributes
    attributes
  end

  def contact_person_attributes
    {main_contact_person: current_user.name, contact_person_email: current_user.email}
  end

  # edit/update
  def find_editable_event
    if current_user.admin
      Event.find(params[:id])
    elsif submissions_are_open
      current_user.editable_events.find(params[:id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def set_event_attributes_for_update!(event, new_attributes)
    new_attributes = new_attributes.clone
    event_times = new_attributes.delete("event_times")

    event.attributes = new_attributes
    event.event_times = []
    event_times.each do |event_time|
      @event.event_times.build(event_time.attributes)
    end
  end

  # create/update
  def event_params
    permitted = params.require(:event).permit(:hosting_location, :main_contact_person, :contact_person_email,
                                              :event_recurrence, :event_description, :title, :fire_art, :red_light, :alcohol)

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
