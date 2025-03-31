OmniAuth.config.logger = Rails.logger
OmniAuth.config.silence_get_warning = true

# Load application ENV vars and merge with existing ENV vars. Loaded here so can use values in initializers.
configs = YAML.load_file('config/application.yml')[Rails.env] rescue {}

configs.merge!(ENV)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, configs["facebook_app_id"], configs["facebook_app_secret"]
  provider :google_oauth2, configs["google_client_id"], configs["google_client_secret"]
end
OmniAuth.config.allowed_request_methods = %i[get]
