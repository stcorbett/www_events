require "rails_helper"

RSpec.describe "Admin::Departments", type: :request do
  before { sign_in_as_admin }

  describe "GET /admin/departments" do
    it "marks an archived associated location" do
      location = create(:location, name: "Archived Department Location")
      create(:department, name: "Department With Archived Location", location: location)
      location.update!(archived: true)

      get admin_departments_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Archived Department Location")
      expect(response.body).to include("this location is archived")
    end
  end

  describe "GET /admin/departments/:id" do
    it "marks an archived associated location" do
      location = create(:location, name: "Archived Department Show Location")
      department = create(:department, name: "Department With Archived Show Location", location: location)
      location.update!(archived: true)

      get admin_department_path(department)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("archived location")
      expect(response.body).to include("this location is archived")
    end
  end
end
