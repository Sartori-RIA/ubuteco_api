require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Back
  class Application < Rails::Application
    config.load_defaults 7.1

    config.api_only = true

    config.time_zone = 'Eastern Time (US & Canada)'

    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = %w[pt-BR en]
    config.i18n.default_locale = :en

    config.navigational_formats = []
    config.middleware.use Rack::Attack
  end
end
