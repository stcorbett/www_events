OmniAuth.config.logger = Rails.logger

# Load application ENV vars and merge with existing ENV vars. Loaded here so can use values in initializers.
# configs = YAML.load_file('config/application.yml')[Rails.env] rescue {}

configs = {
  facebook_app_secret: '2c09b7c34757d0c19314cb791de15ea6',
  facebook_app_id: '906452869379104',
  google_client_id: '16222360144-kusl4truo9v2l3mouqndpkh4u9ftd675.apps.googleusercontent.com',
  google_client_secret: 'fyL1xLT6SbmCY8dcUM2-Xqcb'
}

configs.merge!(ENV)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, configs["facebook_app_id"], configs["facebook_app_secret"]
  provider :google_oauth2, configs["google_client_id"], configs["google_client_secret"]
end
OmniAuth.config.allowed_request_methods = %i[get]
