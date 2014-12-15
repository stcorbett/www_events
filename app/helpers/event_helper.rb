module EventHelper

  def event_is_editable?(event, user)
    user.editable_events.include?(event)
  end

end