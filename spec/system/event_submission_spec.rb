require "rails_helper"

RSpec.describe "Event submission", type: :system do
  let(:user) { create(:user, name: "Ada Camper", email: "ada@example.test") }

  before do
    driven_by :rack_test
    travel_to Time.zone.local(2026, 5, 10, 12, 0, 0)

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: {
        name: user.name,
        email: user.email,
        image: user.image
      },
      credentials: {
        token: user.token,
        expires_at: user.expires_at.to_i
      }
    )
  end

  after do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.test_mode = false
    travel_back
  end

  it "creates an event from the main event form" do
    visit "/auth/google_oauth2"
    visit events_path

    fill_in "event_title", with: "Sunrise Pancake Parade"
    fill_in "event_event_description", with: "A gentle breakfast parade with pancakes, coffee, and small musical surprises."
    check "event_food"
    check "event_spectacle"

    choose "event_where_radio_camp"
    fill_in "event_where_camp_input", with: "Pancake Camp"

    choose "event_who_radio_camp"
    fill_in "event_who_camp_input", with: "Pancake Camp", visible: :all

    fill_in "event_main_contact_person", with: "Ada Camper"
    fill_in "event_contact_person_email", with: "ada@example.test"

    choose "event_event_recurrence_single_val"
    select "Wed - 7/15", from: "event_single_event_time_attributes_0_day_of_week", visible: :all
    fill_in "event_single_event_time_attributes_0_starting", with: "11:00AM", visible: :all
    fill_in "event_single_event_time_attributes_0_ending", with: "12:00PM", visible: :all

    expect do
      click_button "Add"
    end.to change(Event, :count).by(1)

    event = Event.find_by!(title: "Sunrise Pancake Parade")

    expect(page).to have_content("Notice: Event added")
    expect(event.user).to eq(user)
    expect(event.event_description).to include("gentle breakfast parade")
    expect(event.food).to eq(true)
    expect(event.spectacle).to eq(true)
    expect(event.camp.name).to eq("Pancake Camp")
    expect(event.hosting_camp.name).to eq("Pancake Camp")
    expect(event.event_times.first.day_of_week).to eq("Wednesday")
    expect(event.event_times.first.start_time).to eq("11:00AM")
    expect(event.event_times.first.end_time).to eq("12:00PM")
  end
end
