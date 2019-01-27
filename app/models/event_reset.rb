class EventReset
  def self.destroy_all_events
    Event.all.destroy_all
  end
end
