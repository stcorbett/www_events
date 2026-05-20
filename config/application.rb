require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load config/application.yml values into ENV so they're available to
# config/environments/*.rb (which is loaded before initializers). Real
# environment variables — Heroku config vars, shell exports — always win.
application_yml = File.expand_path('application.yml', __dir__)
if File.exist?(application_yml)
  env_section = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
  (YAML.load_file(application_yml)[env_section] || {}).each do |key, value|
    ENV[key.to_s] ||= value.to_s
  end
end

module Application
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :local

    config.eager_load_paths << Rails.root.join("lib")
  end
end


# config.time_zone = 'Eastern Time (US & Canada)'
# config.active_record.default_timezone = :local
# config.autoload_paths += %W(#{config.root}/lib)
