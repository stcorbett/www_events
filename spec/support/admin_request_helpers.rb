module AdminRequestHelpers
  # Stubs current_user to be a fresh admin so admin-only controllers work
  # in request specs without going through OAuth.
  def sign_in_as_admin
    user = create(:user, admin: true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    user
  end

  def sign_in_as_non_admin
    user = create(:user, admin: false)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    user
  end

  # Builds a minimally-valid Event tied to whatever foreign keys you pass.
  # The event_time falls inside the configured-year start/end window so it
  # passes the EventTime "Can't start before Lakes of Fire Starts" validation.
  def create_valid_event(**attrs)
    user = attrs.delete(:user) || User.first || create(:user)
    event = Event.new(
      {
        user: user,
        title: "Spec Event #{SecureRandom.hex(2)}",
        main_contact_person: "Person",
        contact_person_email: "person@example.test",
        event_recurrence: "single",
        event_description: "desc"
      }.merge(attrs)
    )
    start_at = LakesOfFireConfig.start_time + 1.hour
    event.event_times.build(
      starting: start_at,
      ending:   start_at + 1.hour,
      day_of_week: "Wednesday",
      all_day: false
    )
    event.save!
    event
  end
end

RSpec.configure do |config|
  config.include AdminRequestHelpers, type: :request
end
