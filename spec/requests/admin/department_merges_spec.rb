require "rails_helper"

RSpec.describe "Admin::DepartmentMerges", type: :request do
  let!(:source) { create(:department, name: "Source Dept") }
  let!(:target) { create(:department, name: "Target Dept") }
  let!(:archived_dept) { create(:department, name: "Old Dept", archived: true) }
  let(:location) { create(:location) } # events with a department need where_object too

  describe "access control" do
    it "redirects non-admins" do
      sign_in_as_non_admin
      get merge_admin_department_path(source)
      expect(response).to redirect_to(login_path)
    end

    it "redirects logged-out users" do
      get merge_admin_department_path(source)
      expect(response).to redirect_to(login_path)
    end
  end

  describe "as admin" do
    before { sign_in_as_admin }

    describe "GET /admin/departments/:id/merge" do
      it "renders the candidate dropdown excluding self and archived" do
        get merge_admin_department_path(source)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Merge Department: Source Dept")
        expect(response.body).to include("Target Dept")
        expect(response.body).not_to include("Old Dept")
        expect(response.body).not_to include('value="' + source.id.to_s + '"')
      end

      it "redirects to confirm when target_id supplied" do
        get merge_admin_department_path(source), params: { target_id: target.id }

        expect(response).to redirect_to(merge_confirm_admin_department_path(source, target_id: target.id))
      end
    end

    describe "GET /admin/departments/:id/merge/:target_id/confirm" do
      it "renders both records and a Confirm Merge button" do
        get merge_confirm_admin_department_path(source, target_id: target.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Source Dept")
        expect(response.body).to include("Target Dept")
        expect(response.body).to include("Confirm Merge")
      end

      it "404s when the target id is archived" do
        expect {
          get merge_confirm_admin_department_path(source, target_id: archived_dept.id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "POST /admin/departments/:id/merge/:target_id (execute)" do
      it "moves department_id from source to target and redirects to result" do
        e1 = create_valid_event(department: source, location: location, who: "lakes_of_fire")
        e2 = create_valid_event(department: source, location: location, who: "lakes_of_fire")

        post merge_execute_admin_department_path(source, target_id: target.id)

        expect(response).to redirect_to(merge_result_admin_department_path(source, target_id: target.id))
        expect(source.events.reload).to be_empty
        expect(target.events.reload).to match_array([e1, e2])
      end
    end

    describe "GET /admin/departments/:id/merge/:target_id/result" do
      it "renders archive and delete buttons" do
        get merge_result_admin_department_path(source, target_id: target.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Archive Department")
        expect(response.body).to include("Delete Department")
      end
    end

    describe "PATCH archive_source" do
      it "archives the source and redirects to its show page" do
        patch merge_archive_admin_department_path(source, target_id: target.id)

        expect(source.reload.archived).to eq(true)
        expect(response).to redirect_to(admin_department_path(source))
      end
    end

    describe "DELETE delete_source" do
      it "deletes the source and redirects to the target's show page" do
        expect {
          delete merge_delete_admin_department_path(source, target_id: target.id)
        }.to change(Department, :count).by(-1)

        expect(response).to redirect_to(admin_department_path(target))
      end
    end
  end
end
