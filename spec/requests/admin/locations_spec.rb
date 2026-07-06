require "rails_helper"

RSpec.describe "Admin::Locations", type: :request do
  before { sign_in_as_admin }

  describe "GET /admin/locations" do
    it "links to the bulk edit form" do
      get admin_locations_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("bulk edit")
      expect(response.body).to include(bulk_edit_admin_locations_path)
    end

    it "marks archived associated camps and departments" do
      location = create(:location, name: "Associated Records Location")
      camp = create(:camp, name: "Archived Location Camp", location: location)
      department = create(:department, name: "Archived Location Department", location: location)
      camp.update!(archived: true)
      department.update!(archived: true)

      get admin_locations_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Archived Location Camp")
      expect(response.body).to include("this camp is archived")
      expect(response.body).to include("Archived Location Department")
      expect(response.body).to include("this department is archived")
    end
  end

  describe "GET /admin/locations/:id" do
    it "marks archived associated camps and departments" do
      location = create(:location, name: "Associated Records Location")
      camp = create(:camp, name: "Archived Location Camp", location: location)
      department = create(:department, name: "Archived Location Department", location: location)
      camp.update!(archived: true)
      department.update!(archived: true)

      get admin_location_path(location)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Associated Records")
      expect(response.body).to include("this camp is archived")
      expect(response.body).to include("this department is archived")
    end
  end

  describe "GET /admin/locations/bulk_edit" do
    it "lists location rows enhanced with camp and department data and event counts" do
      location = create(:location, name: "The Meadow")
      camp = create(:camp, name: "Camp Spark", location: location)
      department = create(:department, name: "Rangers", location: location)
      standalone_department = create(:department, name: "Sanctuary")
      department_event_location = create(:location, name: "Department Event Location")

      create_valid_event(location: location)
      create_valid_event(camp: camp, hosting_camp: camp)
      previous_event = create_valid_event(location: location, department: department)
      previous_event.update_columns(created_at: Event.configured_year_cutoff - 1.day)
      create_valid_event(location: department_event_location, department: standalone_department)
      standalone_department.update!(archived: true)

      get bulk_edit_admin_locations_path

      expect(response).to have_http_status(:ok)

      document = Nokogiri::HTML(response.body)
      location_row = document.at_css("#bulk_location_location_#{location.id}")
      department_row = document.at_css("#bulk_location_department_#{standalone_department.id}")

      expect(location_row.at_css("strong").text).to eq("The Meadow")
      expect(location_row.text).to include("Camp Spark")
      expect(location_row.text).to include("camp: Camp Spark")
      expect(location_row.text).to include("departments: Rangers")
      expect(location_row.css("td")[2].text.strip).to eq("2")
      expect(location_row.css("td")[3].text.strip).to eq("1")

      expect(department_row.text).to include("Department Sanctuary")
      expect(department_row.css("td")[2].text.strip).to eq("1")
      expect(department_row.css("td")[3].text.strip).to eq("0")
      expect(department_row.at_css("input[type='checkbox']")["checked"]).to eq("checked")
    end
  end

  describe "POST /admin/locations/bulk_update" do
    it "updates posted archive flags and synchronizes associated records" do
      location = create(:location, archived: false)
      camp = create(:camp, location: location, archived: false)
      department = create(:department, location: location, archived: false)
      visible_location = create(:location, archived: false)
      archived_location = create(:location, archived: true)
      standalone_camp = create(:camp, archived: false)
      standalone_department = create(:department, archived: false)

      post bulk_update_admin_locations_path, params: {
        locations: {
          location.id.to_s => { archived: "1" },
          visible_location.id.to_s => { archived: "0" },
          archived_location.id.to_s => { archived: "0" }
        },
        camps: {
          standalone_camp.id.to_s => { archived: "1" }
        },
        departments: {
          standalone_department.id.to_s => { archived: "1" }
        }
      }

      expect(response).to redirect_to(admin_locations_path)
      expect(flash[:notice]).to eq("1 locations archived, 2 visible")

      expect(location.reload.archived).to eq(true)
      expect(camp.reload.archived).to eq(true)
      expect(department.reload.archived).to eq(true)
      expect(visible_location.reload.archived).to eq(false)
      expect(archived_location.reload.archived).to eq(false)
      expect(standalone_camp.reload.archived).to eq(true)
      expect(standalone_department.reload.archived).to eq(true)
    end
  end
end
