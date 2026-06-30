require 'rails_helper'

RSpec.describe "Superadmin events", type: :request do
  describe "GET /superadmin/events" do
    it "redirects non-superadmins" do
      sign_in_as_admin

      get superadmin_events_path

      expect(response).to redirect_to(login_path)
    end

    it "shows the superadmin navigation entry to superadmins" do
      sign_in_as_superadmin

      get superadmin_events_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("superadmin")
      expect(response.body).to include(superadmin_events_path)
    end

    it "lists events with location, camp affiliations, and useful list details" do
      submitter = create(:user, name: "Event Maker", email: "maker@example.test")
      sign_in_as_superadmin

      where_camp = create(:camp, name: "Camp Spark")
      hosting_camp = create(:camp, name: "Camp Glow")
      direct_camp_event = create_valid_event(
        user: submitter,
        title: "Direct Camp Gathering",
        camp: where_camp,
        hosting_camp: hosting_camp,
        main_contact_person: "Camp Contact",
        contact_person_email: "camp@example.test",
        fire_art: true
      )

      location = create(:location, name: "Lake Loop")
      location_camp = create(:camp, name: "Camp Shoreline", location: location)
      previous_year_location_camp = create(
        :camp,
        name: "Camp Old Shoreline",
        year: LakesOfFireConfig.year - 1,
        location: location
      )
      location_event = create_valid_event(
        title: "Location-Based Workshop",
        location: location,
        main_contact_person: "Location Contact",
        contact_person_email: "location@example.test",
        food: true
      )

      department = create(:department, name: "Rangers")
      department_event = create_valid_event(
        title: "Department Briefing",
        location: create(:location, name: "HQ"),
        department: department,
        main_contact_person: "Dept Contact",
        contact_person_email: "dept@example.test"
      )

      get superadmin_events_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(direct_camp_event.title)
      expect(response.body).to include(where_camp.name)
      expect(response.body).to include(hosting_camp.name)
      expect(response.body).to include("Fire art")
      expect(response.body).to include("Camp Contact")
      expect(response.body).to include("camp@example.test")
      expect(response.body).to include("Event Maker / maker@example.test")

      expect(response.body).to include(location_event.title)
      expect(response.body).to include("Lake Loop")
      expect(response.body).to include(location_camp.name)
      expect(response.body).to include(previous_year_location_camp.name)
      expect(response.body).to include("Food")

      expect(response.body).to include(department_event.title)
      expect(response.body).to include("Rangers (department)")
      expect(response.body).to include("Dept Contact")
    end
  end
end
