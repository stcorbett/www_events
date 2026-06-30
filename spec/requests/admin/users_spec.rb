require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  describe "GET /admin/users/:id/edit" do
    it "does not render superadmin controls" do
      user = create(:user, superadmin: false)
      sign_in_as_admin

      get edit_admin_user_path(user)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("Superadmin")
      expect(response.body).not_to include("user_superadmin")
    end
  end

  describe "PATCH /admin/users/:id" do
    it "does not allow admins to set the superadmin flag" do
      user = create(:user, admin: false, superadmin: false)
      sign_in_as_admin

      patch admin_user_path(user), params: {
        user: {
          admin: "1",
          superadmin: "1"
        }
      }

      expect(response).to redirect_to(admin_users_path)
      user.reload
      expect(user.admin).to eq(true)
      expect(user.superadmin).to eq(false)
    end
  end
end
