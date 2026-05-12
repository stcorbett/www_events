OmniAuth.config.logger = Rails.logger
OmniAuth.config.silence_get_warning = true

# Load application ENV vars and merge with existing ENV vars. Loaded here so can use values in initializers.
application_configs = if Rails.root.join('config/application.yml').exist?
  YAML.load_file(Rails.root.join('config/application.yml'))[Rails.env] || {}
else
  {}
end

configs = application_configs.merge(ENV.to_h)

oauth_config_value = lambda do |*keys|
  keys.map { |key| configs[key] }.find { |value| !value.to_s.empty? }
end

facebook_app_id = oauth_config_value.call('facebook_app_id', 'FACEBOOK_APP_ID')
facebook_app_secret = oauth_config_value.call('facebook_app_secret', 'FACEBOOK_APP_SECRET')
google_client_id = oauth_config_value.call('google_client_id', 'GOOGLE_CLIENT_ID')
google_client_secret = oauth_config_value.call('google_client_secret', 'GOOGLE_CLIENT_SECRET')

if Rails.env.test?
  google_client_id ||= 'test-google-client-id'
  google_client_secret ||= 'test-google-client-secret'
end

class GoogleOAuthRequestBlocker
  IN_APP_USER_AGENT = Regexp.new(
    [
      '\\bFB[\\w_]+\\/',
      '\\bInstagram\\b',
      '\\bLine\\/',
      '\\bMicroMessenger\\/',
      '\\bTwitter\\b',
      'WebView',
      '(iPhone|iPod|iPad)(?!.*Safari/)',
      'Android.*(wv)'
    ].join('|'),
    Regexp::IGNORECASE
  )

  def initialize(app, google_configured:)
    @app = app
    @google_configured = google_configured
  end

  def call(env)
    request = Rack::Request.new(env)

    if google_auth_request?(request)
      return redirect('/login?google_auth_config_missing=1') unless @google_configured
      return redirect('/login?in_app_browser=1') if IN_APP_USER_AGENT.match?(request.user_agent.to_s)
    end

    @app.call(env)
  end

  private

  def google_auth_request?(request)
    request.get? && request.path == '/auth/google_oauth2'
  end

  def redirect(location)
    [302, { 'Location' => location, 'Content-Type' => 'text/plain' }, []]
  end
end

Rails.application.config.middleware.use GoogleOAuthRequestBlocker,
  google_configured: !google_client_id.to_s.empty? && !google_client_secret.to_s.empty?

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, facebook_app_id, facebook_app_secret
  provider :google_oauth2, google_client_id, google_client_secret
end
OmniAuth.config.allowed_request_methods = %i[get]
