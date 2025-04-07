module OmniauthHelpers
  def mock_auth_hash
    OmniAuth.config.mock_auth[:google_oauth2]
  end

  def setup_omniauth_mock
    OmniAuth.config.mock_auth[:google_oauth2] = mock_auth_hash
  end
end

RSpec.configure do |config|
  config.include OmniauthHelpers
end
