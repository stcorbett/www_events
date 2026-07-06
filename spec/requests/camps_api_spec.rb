require "rails_helper"

RSpec.describe "Camps API", type: :request do
  describe "GET /camps.json" do
    it "returns visible current-year camps with year and event counts" do
      current_location = create(:location, name: "Current Camp Location")
      current_camp = create(:camp, name: "Current Camp", year: LakesOfFireConfig.year, location: current_location)
      previous_camp = create(:camp, name: "Previous Camp", year: LakesOfFireConfig.year - 1)
      archived_camp = create(:camp, name: "Archived Camp", year: LakesOfFireConfig.year, archived: true)
      location = create(:location, name: "Roaming Spot")

      create_valid_event(camp: current_camp, hosting_camp: current_camp)
      create_valid_event(location: location, hosting_camp: current_camp)
      current_location.update!(archived: true)

      get camps_path(format: :json)

      expect(response).to have_http_status(:ok)

      payload = JSON.parse(response.body)
      camps = payload.fetch("coalesce").fetch("coalesce")
      names = camps.map { |camp| camp.fetch("name") }
      current_payload = camps.find { |camp| camp.fetch("id") == current_camp.id }

      expect(names).to include(current_camp.name)
      expect(names).not_to include(previous_camp.name)
      expect(names).not_to include(archived_camp.name)
      expect(current_payload).to include(
        "year" => LakesOfFireConfig.year,
        "location_archived" => true,
        "event_count" => 1,
        "hosted_event_count" => 2
      )
    end
  end
end
