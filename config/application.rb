# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Back
  class Application < Rails::Application
    config.load_defaults 6.1

    ENV.update YAML.load_file('config/application.yml')[Rails.env] unless Rails.env.production?

    config.api_only = true

    config.time_zone = 'Brasilia'

    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = ['pt-BR']
    config.i18n.default_locale = :'pt-BR'

    config.navigational_formats = []

    config.middleware.use Rack::Attack
  end
end
