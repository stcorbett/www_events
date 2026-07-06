require "rails_helper"

RSpec.describe "Admin::Camps", type: :request do
  before { sign_in_as_admin }

  def section_text(id)
    Nokogiri::HTML(response.body).at_css("##{id}").text
  end

  def camp_index_cells(camp)
    Nokogiri::HTML(response.body).css("tr#camp_#{camp.id} td").map { |cell| cell.text.squish }
  end

  describe "GET /admin/camps" do
    it "shows current camps by default and lists previous years as tabs" do
      current_camp = create(:camp, name: "Current Year Camp", year: LakesOfFireConfig.year)
      previous_camp = create(:camp, name: "Previous Year Camp", year: LakesOfFireConfig.year - 1)

      get admin_camps_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("this year")
      expect(response.body).to include((LakesOfFireConfig.year - 1).to_s)
      expect(response.body).to include(current_camp.name)
      expect(response.body).not_to include(previous_camp.name)
    end

    it "shows camps for the selected previous year" do
      current_camp = create(:camp, name: "Current Year Camp", year: LakesOfFireConfig.year)
      previous_camp = create(:camp, name: "Previous Year Camp", year: LakesOfFireConfig.year - 1)

      get admin_camps_path(year: LakesOfFireConfig.year - 1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(previous_camp.name)
      expect(response.body).not_to include(current_camp.name)
    end

    it "marks an archived associated location" do
      location = create(:location, name: "Archived Camp Location", camp_site_identifier: "A12")
      create(:camp, name: "Camp With Archived Location", location: location)
      location.update!(archived: true)

      get admin_camps_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("A12")
      expect(response.body).to include("this location is archived")
    end

    it "does not show a fallback location name for unnamed camp location records" do
      unnamed_location = create(:location, name: nil, camp_site_identifier: nil)
      site_id_location = create(:location, name: nil, camp_site_identifier: "C34")
      named_location = create(:location, name: "Named Camp Location", camp_site_identifier: nil)
      unnamed_camp = create(:camp, name: "Camp With Default Location", location: unnamed_location)
      site_id_camp = create(:camp, name: "Camp With Site ID Location", location: site_id_location)
      named_location_camp = create(:camp, name: "Camp With Named Location", location: named_location)

      get admin_camps_path

      expect(response).to have_http_status(:ok)
      expect(camp_index_cells(unnamed_camp)[2]).to eq("")
      expect(camp_index_cells(site_id_camp)[2]).to include("C34")
      expect(camp_index_cells(named_location_camp)[2]).to include("Named Camp Location")
      expect(response.body).not_to include("location ##{unnamed_location.id}")
    end

    it "only shows event time counts in parens when they differ from current-year event counts" do
      current_only_camp = create(:camp, name: "Camp With One Time")
      two_time_camp = create(:camp, name: "Camp With Two Times")
      create_valid_event(title: "Single Time Event", camp: current_only_camp, hosting_camp: current_only_camp)
      two_time_event = create_valid_event(title: "Multi Time Event", camp: two_time_camp, hosting_camp: two_time_camp)
      start_at = LakesOfFireConfig.start_time + 2.hours
      two_time_event.event_times.create!(
        starting: start_at,
        ending: start_at + 1.hour,
        day_of_week: "Wednesday"
      )

      get admin_camps_path

      expect(response).to have_http_status(:ok)
      headers = Nokogiri::HTML(response.body).css("#camps-table th").map { |header| header.text.squish }
      expect(headers).to eq(["Name", "Events (#{LakesOfFireConfig.year})", "Site ID", "Actions"])
      expect(camp_index_cells(current_only_camp)[1]).to eq("1")
      expect(camp_index_cells(two_time_camp)[1]).to eq("1 (2)")
    end
  end

  describe "GET /admin/camps/:id" do
    it "splits current events by this camp's role" do
      camp = create(:camp, name: "Camp Role Split")
      other_camp = create(:camp, name: "Other Role Camp")
      create_valid_event(
        title: "Owned Here",
        camp: camp,
        hosting_camp: camp
      )
      create_valid_event(
        title: "Guest Operating Here",
        camp: camp,
        hosting_camp: other_camp
      )
      create_valid_event(
        title: "Camp Organizing Elsewhere",
        camp: other_camp,
        hosting_camp: camp
      )

      get admin_camp_path(camp)

      expect(response).to have_http_status(:ok)
      expect(section_text("camp-owned-events")).to include("Owned Here")
      expect(section_text("camp-owned-events")).not_to include("Guest Operating Here")
      expect(section_text("camp-owned-events")).not_to include("Camp Organizing Elsewhere")

      expect(section_text("camp-events-at-camp")).to include("Guest Operating Here")
      expect(section_text("camp-events-at-camp")).to include("Other Role Camp (camp)")
      expect(section_text("camp-events-at-camp")).not_to include("Owned Here")
      expect(section_text("camp-events-at-camp")).not_to include("Camp Organizing Elsewhere")

      expect(section_text("camp-organizing-events")).to include("Camp Organizing Elsewhere")
      expect(section_text("camp-organizing-events")).to include("Other Role Camp (camp)")
      expect(section_text("camp-organizing-events")).not_to include("Owned Here")
      expect(section_text("camp-organizing-events")).not_to include("Guest Operating Here")
    end

    it "shows events organized by the camp even when they happen at a different camp" do
      where_camp = create(:camp, name: "Where Camp")
      hosting_camp = create(:camp, name: "Hosting Camp")
      create_valid_event(
        title: "Hosted Somewhere Else",
        camp: where_camp,
        hosting_camp: hosting_camp
      )

      get admin_camp_path(hosting_camp)

      expect(response).to have_http_status(:ok)
      expect(section_text("camp-owned-events")).to include("No current events are both hosted by and located at this camp.")
      expect(section_text("camp-organizing-events")).to include("Hosted Somewhere Else")
      expect(section_text("camp-organizing-events")).to include("Where Camp (camp)")
    end

    it "does not duplicate events that are both at and hosted by the camp in the organizing section" do
      camp = create(:camp, name: "Camp Both")
      other_camp = create(:camp, name: "Other Camp")
      create_valid_event(
        title: "Hosted At Its Own Camp",
        camp: camp,
        hosting_camp: camp
      )
      create_valid_event(
        title: "Hosted At Another Camp",
        camp: other_camp,
        hosting_camp: camp
      )

      get admin_camp_path(camp)

      expect(response).to have_http_status(:ok)
      expect(response.body.scan("Hosted At Its Own Camp").size).to eq(1)
      expect(section_text("camp-owned-events")).to include("Hosted At Its Own Camp")
      expect(section_text("camp-organizing-events")).not_to include("Hosted At Its Own Camp")
      expect(section_text("camp-organizing-events")).to include("Hosted At Another Camp")
      expect(section_text("camp-organizing-events")).to include("Other Camp (camp)")
    end

    it "merges past events and shows details for external roles" do
      camp = create(:camp, name: "Past Camp")
      other_camp = create(:camp, name: "Other Past Camp")
      past_time = Event.configured_year_cutoff - 1.day

      internal_event = create_valid_event(
        title: "Past Owned Here",
        camp: camp,
        hosting_camp: camp
      )
      guest_event = create_valid_event(
        title: "Past Guest Operating Here",
        camp: camp,
        hosting_camp: other_camp
      )
      elsewhere_event = create_valid_event(
        title: "Past Organizing Elsewhere",
        camp: other_camp,
        hosting_camp: camp
      )
      [internal_event, guest_event, elsewhere_event].each do |event|
        event.update_columns(created_at: past_time, updated_at: past_time)
      end

      get admin_camp_path(camp)

      past_events = section_text("camp-past-events")
      expect(response).to have_http_status(:ok)
      expect(past_events).to include("Past Owned Here")
      expect(past_events).to include("Past Guest Operating Here")
      expect(past_events).to include("Other Past Camp (camp) operating")
      expect(past_events).to include("Past Organizing Elsewhere")
      expect(past_events).to include("at Other Past Camp (camp)")
    end

    it "marks an archived associated location" do
      location = create(:location, name: "Archived Show Location")
      camp = create(:camp, name: "Camp With Archived Show Location", location: location)
      location.update!(archived: true)

      get admin_camp_path(camp)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("archived location")
      expect(response.body).to include("this location is archived")
    end

    it "only shows the location name row when the camp location has a name" do
      location = create(:location, name: nil, camp_site_identifier: "B12")
      camp = create(:camp, name: "Camp With Default Location", location: location)

      get admin_camp_path(camp)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("<strong>Location:</strong>")
      expect(response.body).not_to include("location ##{location.id}")
      expect(response.body).to include("<strong>Site Identifier:</strong>")
      expect(response.body).to include("B12")
    end
  end
end
