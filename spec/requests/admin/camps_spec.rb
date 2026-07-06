require "rails_helper"

RSpec.describe "Admin::Camps", type: :request do
  before { sign_in_as_admin }

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
  end

  describe "GET /admin/camps/:id" do
    it "shows events hosted by the camp even when they happen at a different camp" do
      where_camp = create(:camp, name: "Where Camp")
      hosting_camp = create(:camp, name: "Hosting Camp")
      create_valid_event(
        title: "Hosted Somewhere Else",
        camp: where_camp,
        hosting_camp: hosting_camp
      )

      get admin_camp_path(hosting_camp)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("No events are currently associated with this camp.")
      expect(response.body).to include("Hosted Events by this Camp")
      expect(response.body).to include("Hosted Somewhere Else")
      expect(response.body).to include("Where Camp (camp)")
    end

    it "does not duplicate events that are both at and hosted by the camp in the hosted section" do
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
      expect(response.body).to include("Hosted At Another Camp")
      expect(response.body).to include("Other Camp (camp)")
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
  end
end
