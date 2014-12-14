OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, "906452869379104", "eddac7e4f6dab30d06f8337cd1e8814f"
end