require "rails_helper"

RSpec.describe "Events", type: :request do
  describe "GET /events/:id" do
    it "marks archived where and who records for admins" do
      sign_in_as_admin
      where_camp = create(:camp, name: "Archived Where Camp")
      hosting_camp = create(:camp, name: "Archived Hosting Camp")
      event = create_valid_event(camp: where_camp, hosting_camp: hosting_camp)
      where_camp.update!(archived: true)
      hosting_camp.update!(archived: true)

      get event_path(event)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Archived Where Camp")
      expect(response.body).to include("Archived Hosting Camp")
      expect(response.body.scan("this camp is archived").size).to be >= 2
    end
  end
end
