require "rails_helper"

RSpec.describe "Admin::CampMerges", type: :request do
  let!(:source) { create(:camp, name: "Source Camp") }
  let!(:target) { create(:camp, name: "Target Camp") }
  let!(:archived_camp) { create(:camp, name: "Old Camp", archived: true) }

  describe "access control" do
    it "redirects non-admins away from the merge entry" do
      sign_in_as_non_admin
      get merge_admin_camp_path(source)
      expect(response).to redirect_to(login_path)
    end

    it "redirects logged-out users from the merge entry" do
      get merge_admin_camp_path(source)
      expect(response).to redirect_to(login_path)
    end
  end

  describe "as admin" do
    before { sign_in_as_admin }

    describe "GET /admin/camps/:id/merge" do
      it "renders the dropdown of mergeable candidates" do
        get merge_admin_camp_path(source)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Merge Camp: Source Camp")
        expect(response.body).to include("Target Camp")
        expect(response.body).not_to include("Old Camp")      # archived
        expect(response.body).not_to include('value="' + source.id.to_s + '"') # never lists self
      end

      it "redirects to the confirmation page when target_id is supplied" do
        get merge_admin_camp_path(source), params: { target_id: target.id }

        expect(response).to redirect_to(merge_confirm_admin_camp_path(source, target_id: target.id))
      end
    end

    describe "GET /admin/camps/:id/merge/:target_id/confirm" do
      it "renders both records side-by-side" do
        get merge_confirm_admin_camp_path(source, target_id: target.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Source Camp")
        expect(response.body).to include("Target Camp")
        expect(response.body).to include("Confirm Merge")
      end

      it "404s when the target id is for an archived camp" do
        expect {
          get merge_confirm_admin_camp_path(source, target_id: archived_camp.id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "POST /admin/camps/:id/merge/:target_id (execute)" do
      it "moves both camp_id and hosting_camp_id from source to target, then redirects to result" do
        e1 = create_valid_event(camp: source, hosting_camp: target)
        e2 = create_valid_event(camp: target, hosting_camp: source)
        e3 = create_valid_event(camp: source, hosting_camp: source)

        post merge_execute_admin_camp_path(source, target_id: target.id)

        expect(response).to redirect_to(merge_result_admin_camp_path(source, target_id: target.id))
        [e1, e2, e3].each(&:reload)
        expect(source.events.reload).to be_empty
        expect(source.hosted_events.reload).to be_empty
        expect(target.events.reload).to match_array([e1, e2, e3])
        expect(target.hosted_events.reload).to match_array([e1, e2, e3])
      end

      it "does not touch unrelated events" do
        unrelated_camp = create(:camp, name: "Other")
        unrelated_event = create_valid_event(camp: unrelated_camp, hosting_camp: unrelated_camp)

        post merge_execute_admin_camp_path(source, target_id: target.id)

        unrelated_event.reload
        expect(unrelated_event.camp).to eq(unrelated_camp)
        expect(unrelated_event.hosting_camp).to eq(unrelated_camp)
      end
    end

    describe "GET /admin/camps/:id/merge/:target_id/result" do
      it "renders the post-merge page with archive and delete buttons targeting the source" do
        get merge_result_admin_camp_path(source, target_id: target.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Merge Complete")
        expect(response.body).to include("Archive Camp")
        expect(response.body).to include("Delete Camp")
      end
    end

    describe "PATCH /admin/camps/:id/merge/:target_id/archive (archive_source)" do
      it "archives the source camp and redirects to its show page" do
        patch merge_archive_admin_camp_path(source, target_id: target.id)

        expect(source.reload.archived).to eq(true)
        expect(response).to redirect_to(admin_camp_path(source))
      end
    end

    describe "DELETE /admin/camps/:id/merge/:target_id/delete (delete_source)" do
      it "deletes the source camp and redirects to the target's show page" do
        expect {
          delete merge_delete_admin_camp_path(source, target_id: target.id)
        }.to change(Camp, :count).by(-1)

        expect(response).to redirect_to(admin_camp_path(target))
        expect(Camp.exists?(source.id)).to eq(false)
      end

      it "redirects to the result page when delete is blocked (e.g. source still has events)" do
        # Leave an event on the source so Camp#check_for_events aborts the destroy.
        create_valid_event(camp: source, hosting_camp: target)

        expect {
          delete merge_delete_admin_camp_path(source, target_id: target.id)
        }.not_to change(Camp, :count)

        expect(response).to redirect_to(merge_result_admin_camp_path(source, target_id: target.id))
      end
    end
  end
end
