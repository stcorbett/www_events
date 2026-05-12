require "rails_helper"

RSpec.describe "Admin::LocationMerges", type: :request do
  let!(:source) { create(:location, name: "Source Loc") }
  let!(:target) { create(:location, name: "Target Loc") }
  let!(:archived_loc) { create(:location, name: "Old Loc", archived: true) }

  describe "access control" do
    it "redirects non-admins" do
      sign_in_as_non_admin
      get merge_admin_location_path(source)
      expect(response).to redirect_to(login_path)
    end

    it "redirects logged-out users" do
      get merge_admin_location_path(source)
      expect(response).to redirect_to(login_path)
    end
  end

  describe "as admin" do
    before { sign_in_as_admin }

    describe "GET /admin/locations/:id/merge" do
      it "renders the candidate dropdown excluding self and archived" do
        get merge_admin_location_path(source)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Merge Location: Source Loc")
        expect(response.body).to include("Target Loc")
        expect(response.body).not_to include("Old Loc")
        expect(response.body).not_to include('value="' + source.id.to_s + '"')
      end

      it "redirects to confirm when target_id is supplied" do
        get merge_admin_location_path(source), params: { target_id: target.id }

        expect(response).to redirect_to(merge_confirm_admin_location_path(source, target_id: target.id))
      end
    end

    describe "GET confirm" do
      it "renders both records and a Confirm Merge button" do
        get merge_confirm_admin_location_path(source, target_id: target.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Source Loc")
        expect(response.body).to include("Target Loc")
        expect(response.body).to include("Confirm Merge")
      end

      it "404s when the target id is archived" do
        expect {
          get merge_confirm_admin_location_path(source, target_id: archived_loc.id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "POST execute" do
      it "moves location_id from source to target and redirects to result" do
        e1 = create_valid_event(location: source)
        e2 = create_valid_event(location: source)

        post merge_execute_admin_location_path(source, target_id: target.id)

        expect(response).to redirect_to(merge_result_admin_location_path(source, target_id: target.id))
        expect(source.events.reload).to be_empty
        expect(target.events.reload).to match_array([e1, e2])
      end
    end

    describe "GET result" do
      it "renders archive and delete buttons" do
        get merge_result_admin_location_path(source, target_id: target.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Archive Location")
        expect(response.body).to include("Delete Location")
      end
    end

    describe "PATCH archive_source" do
      it "archives the source and redirects to its show page" do
        patch merge_archive_admin_location_path(source, target_id: target.id)

        expect(source.reload.archived).to eq(true)
        expect(response).to redirect_to(admin_location_path(source))
      end
    end

    describe "DELETE delete_source" do
      it "deletes the source and redirects to the target's show page" do
        expect {
          delete merge_delete_admin_location_path(source, target_id: target.id)
        }.to change(Location, :count).by(-1)

        expect(response).to redirect_to(admin_location_path(target))
      end
    end

    # The merge-validation rule specific to Location.
    describe "merge gate (location-specific)" do
      it "blocks the merge flow at /merge when a camp is still attached to the source" do
        Camp.create!(name: "Blocking Camp", location: source)

        get merge_admin_location_path(source)

        expect(response).to redirect_to(edit_admin_location_path(source))
        expect(flash[:error]).to include("Cannot merge")
        expect(flash[:error]).to include("Blocking Camp")
      end

      it "blocks the merge flow when a department is still attached to the source" do
        Department.create!(name: "Blocking Dept", location: source)

        get merge_admin_location_path(source)

        expect(response).to redirect_to(edit_admin_location_path(source))
        expect(flash[:error]).to include("Cannot merge")
        expect(flash[:error]).to include("department")
      end

      it "blocks confirm and execute too, not just the merge entry" do
        Camp.create!(name: "Blocking Camp", location: source)

        get merge_confirm_admin_location_path(source, target_id: target.id)
        expect(response).to redirect_to(edit_admin_location_path(source))

        post merge_execute_admin_location_path(source, target_id: target.id)
        expect(response).to redirect_to(edit_admin_location_path(source))
      end

      it "still allows the result/archive/delete actions after a merge has happened (gate skipped post-merge)" do
        # Simulate a state where the source had a merge run and is now empty,
        # but a camp got attached later somehow. The post-merge cleanup
        # actions should still be reachable.
        Camp.create!(name: "Late-attached Camp", location: source)

        patch merge_archive_admin_location_path(source, target_id: target.id)

        expect(response).to redirect_to(admin_location_path(source))
        expect(source.reload.archived).to eq(true)
      end
    end
  end
end
