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
  end
end
