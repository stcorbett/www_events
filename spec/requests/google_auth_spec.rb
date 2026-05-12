require "rails_helper"

RSpec.describe "Google authentication", type: :request do
  let(:facebook_iphone_user_agent) do
    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) " \
      "AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 " \
      "[FBAN/FBIOS;FBAV/1.0]"
  end

  it "redirects in-app browsers away from Google OAuth" do
    get "/auth/google_oauth2", headers: { "HTTP_USER_AGENT" => facebook_iphone_user_agent }

    expect(response).to redirect_to("/login?in_app_browser=1")
  end

  it "shows the in-app browser warning without a Google login link" do
    get "/login", params: { in_app_browser: "1" }

    expect(response.body).to include("In-app browser detected.")
    expect(response.body).not_to include('href="/auth/google_oauth2"')
  end

  it "shows a local configuration warning without a Google login link" do
    get "/login", params: { google_auth_config_missing: "1" }

    expect(response.body).to include("Google login is not configured.")
    expect(response.body).not_to include('href="/auth/google_oauth2"')
  end
end

RSpec.describe GoogleOAuthRequestBlocker do
  let(:app) { ->(_) { [200, {}, ["ok"]] } }

  it "redirects Google OAuth requests when credentials are missing" do
    response = described_class.new(app, google_configured: false).call(
      Rack::MockRequest.env_for("/auth/google_oauth2", method: "GET")
    )

    expect(response[0]).to eq(302)
    expect(response[1]["Location"]).to eq("/login?google_auth_config_missing=1")
  end
end
