require "rails_helper"

RSpec.describe "Public API archiving", type: :request do
  def api_rows
    JSON.parse(response.body).fetch("coalesce").fetch("coalesce")
  end

  describe "GET /locations.json" do
    it "does not include archived locations as top-level location records" do
      visible_location = create(:location, name: "Visible Location")
      archived_location = create(:location, name: "Archived Location", archived: true)

      get locations_path(format: :json)

      names = api_rows.map { |location| location.fetch("name") }
      expect(names).to include(visible_location.name)
      expect(names).not_to include(archived_location.name)
    end
  end

  describe "GET /departments.json" do
    it "does not include archived departments as top-level department records" do
      visible_department = create(:department, name: "Visible Department")
      archived_department = create(:department, name: "Archived Department", archived: true)

      get departments_path(format: :json)

      names = api_rows.map { |department| department.fetch("name") }
      expect(names).to include(visible_department.name)
      expect(names).not_to include(archived_department.name)
    end
  end

  describe "GET /events.json" do
    it "keeps events visible but flags archived associated records" do
      where_camp = create(:camp, name: "Archived Where Camp")
      hosting_camp = create(:camp, name: "Archived Hosting Camp")
      camp_event = create_valid_event(
        title: "Camp Event With Archived Associations",
        camp: where_camp,
        hosting_camp: hosting_camp
      )

      event_location = create(:location, name: "Archived Event Location")
      department = create(:department, name: "Archived Event Department")
      department_event = create_valid_event(
        title: "Department Event With Archived Associations",
        location: event_location,
        department: department
      )

      where_camp.update!(archived: true)
      hosting_camp.update!(archived: true)
      event_location.update!(archived: true)
      department.update!(archived: true)

      get events_path(format: :json)

      camp_payload = api_rows.find { |event| event.fetch("event_id") == camp_event.id }
      department_payload = api_rows.find { |event| event.fetch("event_id") == department_event.id }

      expect(camp_payload).to include(
        "where_name" => where_camp.name,
        "where_archived" => true,
        "who_name" => hosting_camp.name,
        "who_archived" => true
      )
      expect(department_payload).to include(
        "where_name" => event_location.name,
        "where_archived" => true,
        "who_name" => department.name,
        "who_archived" => true
      )
    end
  end
end
