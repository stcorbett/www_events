require "rails_helper"

RSpec.describe "Event submission", type: :system do
  let(:user) { create(:user, name: "Ada Camper", email: "ada@example.test") }

  scenarios = [
    {
      title: "Sunrise Pancake Parade",
      where: { type: :camp, name: "Pancake Camp" },
      who: { type: :camp, name: "Pancake Camp" },
      when: { type: :single, day: "Wed - 7/15", start: "11:00AM", ending: "12:00PM" },
      categories: %w[event_food event_spectacle]
    },
    {
      title: "Lantern Repair Office Hours",
      where: { type: :location, name: "The Spark Lab" },
      who: { type: :department, name: "Artery" },
      when: {
        type: :multiple,
        times: [
          { index: 0, day: "Wednesday", start: "1:00PM", ending: "2:00PM" },
          { index: 2, day: "Friday", start: "3:00PM", ending: "4:30PM" }
        ]
      },
      categories: %w[event_crafting]
    },
    {
      title: "Wandering Compliment Delivery",
      where: { type: :multiple_locations, name: "Where the music is kindest" },
      who: { type: :just_me },
      when: { type: :single, day: "Sat - 7/18", start: "6:00PM", ending: "7:15PM" },
      categories: %w[event_sober event_kid_friendly]
    }
  ]

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

  scenarios.each do |scenario|
    it "creates an event with #{scenario[:where][:type]} where, #{scenario[:who][:type]} who, and #{scenario[:when][:type]} time" do
      Department.create!(name: scenario[:who][:name]) if scenario[:who][:type] == :department

      submit_event(scenario)

      event = Event.find_by!(title: scenario[:title])

      expect(page).to have_content("Notice: Event added")
      expect(event.user).to eq(user)
      expect(event.event_description).to include(scenario[:title].downcase)
      expect_event_where(event, scenario[:where])
      expect_event_who(event, scenario[:who])
      expect_event_when(event, scenario[:when])
      scenario[:categories].each do |category|
        expect(event.public_send(category.delete_prefix("event_"))).to eq(true)
      end
    end
  end

  it "does not offer or attach previous-year camps from the event camp interface" do
    previous_year_camp = create(:camp, name: "Previous Year Camp", year: LakesOfFireConfig.year - 1)
    current_year_camp = create(:camp, name: "Current Year Camp", year: LakesOfFireConfig.year)

    visit "/auth/google_oauth2"
    visit events_path

    expect(page.html).to include(current_year_camp.name)
    expect(page.html).not_to include(previous_year_camp.name)

    fill_in "event_title", with: "Historic Camp Test"
    fill_in "event_event_description", with: "historic camp test with a clear description for the guide."

    choose "event_where_radio_camp"
    fill_in "event_where_camp_input", with: previous_year_camp.name, visible: :all
    find("#event_where_camp_id_input", visible: :all).set(previous_year_camp.id)

    choose "event_who_radio_camp"
    fill_in "event_who_camp_input", with: previous_year_camp.name, visible: :all
    find("#event_hosting_camp_id_input", visible: :all).set(previous_year_camp.id)

    fill_in "event_main_contact_person", with: "Ada Camper"
    fill_in "event_contact_person_email", with: "ada@example.test"
    fill_single_time(type: :single, day: "Wed - 7/15", start: "11:00AM", ending: "12:00PM")

    expect do
      click_button "Add"
    end.to change(Event, :count).by(1)

    event = Event.find_by!(title: "Historic Camp Test")
    expect(event.camp).not_to eq(previous_year_camp)
    expect(event.camp.name).to eq(previous_year_camp.name)
    expect(event.camp.year).to eq(LakesOfFireConfig.year)
    expect(event.hosting_camp).to eq(event.camp)
  end

  def submit_event(scenario)
    visit "/auth/google_oauth2"
    visit events_path

    fill_in "event_title", with: scenario[:title]
    fill_in "event_event_description", with: "#{scenario[:title].downcase} with a clear description for the guide."
    scenario[:categories].each { |category| check category }

    fill_where(scenario[:where])
    fill_who(scenario[:who])

    fill_in "event_main_contact_person", with: "Ada Camper"
    fill_in "event_contact_person_email", with: "ada@example.test"

    fill_when(scenario[:when])

    expect do
      click_button "Add"
    end.to change(Event, :count).by(1)
  end

  def fill_where(where)
    case where[:type]
    when :camp
      choose "event_where_radio_camp"
      fill_in "event_where_camp_input", with: where[:name], visible: :all
    when :location
      choose "event_where_location_val"
      fill_in "event_where_location_input", with: where[:name], visible: :all
    when :multiple_locations
      choose "event_where_multiple_locations"
      fill_in "event_where_imprecise_input", with: where[:name], visible: :all
    end
  end

  def fill_who(who)
    case who[:type]
    when :camp
      choose "event_who_radio_camp"
      fill_in "event_who_camp_input", with: who[:name], visible: :all
    when :department
      choose "event_who_lakes_of_fire"
      select who[:name], from: "event_department_id_input", visible: :all
    when :just_me
      choose "event_who_just_me"
    end
  end

  def fill_when(when_config)
    case when_config[:type]
    when :single
      fill_single_time(when_config)
    when :multiple
      fill_multiple_times(when_config[:times])
    end
  end

  def fill_single_time(when_config)
    choose "event_event_recurrence_single_val"
    select when_config[:day], from: "event_single_event_time_attributes_0_day_of_week", visible: :all
    fill_in "event_single_event_time_attributes_0_starting", with: when_config[:start], visible: :all
    fill_in "event_single_event_time_attributes_0_ending", with: when_config[:ending], visible: :all
  end

  def fill_multiple_times(times)
    choose "event_event_recurrence_multiple_val"
    times.each do |time|
      fill_in "event_event_times_attributes_#{time[:index]}_starting", with: time[:start], visible: :all
      fill_in "event_event_times_attributes_#{time[:index]}_ending", with: time[:ending], visible: :all
    end
  end

  def expect_event_where(event, where)
    case where[:type]
    when :camp
      expect(event.where).to eq("camp")
      expect(event.camp.name).to eq(where[:name])
    when :location
      expect(event.where).to eq("location")
      expect(event.location.name).to eq(where[:name])
      expect(event.location.precision).to eq("specific")
    when :multiple_locations
      expect(event.where).to eq("multiple_locations")
      expect(event.location.name).to eq(where[:name])
      expect(event.location.precision).to eq("broad")
    end
  end

  def expect_event_who(event, who)
    case who[:type]
    when :camp
      expect(event.who).to eq("camp")
      expect(event.hosting_camp.name).to eq(who[:name])
    when :department
      expect(event.who).to eq("lakes_of_fire")
      expect(event.department.name).to eq(who[:name])
    when :just_me
      expect(event.who).to eq("just_me")
      expect(event.hosting_camp).to be_nil
      expect(event.department).to be_nil
      expect(event.human_who).to eq("Ada Camper")
    end
  end

  def expect_event_when(event, when_config)
    case when_config[:type]
    when :single
      event_time = event.event_times.sole
      expect(event.event_recurrence).to eq("single")
      expect(event_time.starting.strftime("%a - %-m/%-d")).to eq(when_config[:day])
      expect(event_time.start_time.strip).to eq(when_config[:start])
      expect(event_time.end_time.strip).to eq(when_config[:ending])
    when :multiple
      event_times = event.event_times.order(:starting)
      expect(event.event_recurrence).to eq("multiple")
      expect(event_times.count).to eq(when_config[:times].count)
      when_config[:times].zip(event_times).each do |expected_time, event_time|
        expect(event_time.day_of_week).to eq(expected_time[:day])
        expect(event_time.start_time.strip).to eq(expected_time[:start])
        expect(event_time.end_time.strip).to eq(expected_time[:ending])
      end
    end
  end
end
