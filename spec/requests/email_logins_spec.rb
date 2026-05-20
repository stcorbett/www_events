require "rails_helper"

RSpec.describe "Email logins", type: :request do
  before do
    ActionMailer::Base.deliveries.clear
  end

  describe "GET /login/email" do
    it "renders the form with both buttons" do
      get email_login_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Send Login Email")
      expect(response.body).to include("Create Account")
    end
  end

  describe 'POST /login/email — "Send Login Email" branch' do
    context "when the email belongs to an existing user" do
      it "sends a login email and redirects to the sent page" do
        existing = create(:user, email: "Existing@Example.test")

        post email_login_path, params: { email: "existing@example.test", commit: "Send Login Email" }

        expect(response).to redirect_to(email_login_sent_path)
        expect(ActionMailer::Base.deliveries.size).to eq(1)
        expect(ActionMailer::Base.deliveries.last.to).to eq([existing.email])
      end
    end

    context "when no account exists for the email" do
      it "re-renders the form with an error and sends no email" do
        post email_login_path, params: { email: "nobody@example.test", commit: "Send Login Email" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("find an account for nobody@example.test")
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context "when the email is blank" do
      it "re-renders the form with an error" do
        post email_login_path, params: { email: "", commit: "Send Login Email" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Please enter your email address")
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  describe 'POST /login/email — "Create Account" branch' do
    context "when no account exists yet" do
      it "creates the user, sends a login email, and redirects to the sent page" do
        expect {
          post email_login_path, params: { email: "newperson@example.test", commit: "Create Account" }
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(email_login_sent_path)
        user = User.find_by(email: "newperson@example.test")
        expect(user.provider).to eq("email")
        expect(user.uid).to eq("newperson@example.test")
        expect(ActionMailer::Base.deliveries.last.to).to eq(["newperson@example.test"])
      end
    end

    context "when an account with that email already exists" do
      it "re-renders the form with an error and does not create a duplicate" do
        create(:user, email: "alreadyhere@example.test")

        expect {
          post email_login_path, params: { email: "alreadyhere@example.test", commit: "Create Account" }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("already exists")
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  describe "GET /login/email/sent" do
    it "renders the check-your-email page" do
      get email_login_sent_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Click the link in your email to log in")
    end
  end

  describe "GET /login/email/:token (authenticate)" do
    it "signs the user in with a valid token and redirects to root" do
      user = create(:user, email: "valid@example.test")
      token = user.signed_id(purpose: EmailLoginsController::SIGNED_ID_PURPOSE, expires_in: 1.hour)

      get email_login_authenticate_path(token)

      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(user.id)
    end

    it "redirects back to the email login page with an error on a bad token" do
      get email_login_authenticate_path("not-a-valid-token")

      expect(response).to redirect_to(email_login_path)
      expect(flash[:alert]).to include("invalid or has expired")
      expect(session[:user_id]).to be_nil
    end

    it "rejects a token with the wrong purpose (signed with a different purpose)" do
      user = create(:user)
      wrong_token = user.signed_id(purpose: :something_else, expires_in: 1.hour)

      get email_login_authenticate_path(wrong_token)

      expect(response).to redirect_to(email_login_path)
      expect(session[:user_id]).to be_nil
    end

    it "rejects an expired token" do
      user = create(:user)
      token = nil
      travel_to 2.hours.ago do
        token = user.signed_id(purpose: EmailLoginsController::SIGNED_ID_PURPOSE, expires_in: 1.hour)
      end

      get email_login_authenticate_path(token)

      expect(response).to redirect_to(email_login_path)
      expect(session[:user_id]).to be_nil
    end
  end
end
