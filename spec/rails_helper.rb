ENV['RAILS_ENV'] ||= 'test'
require 'support/simplecov'
require 'spec_helper'

require File.expand_path('../config/environment', __dir__)

abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'support/shoulda'
require 'support/factory_bot'
require 'support/database_cleaner'
require 'devise/jwt/test_helpers'
require 'money-rails/test_helpers'
require 'support/file_spec_helper'
require 'support/helpers/headers'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  config.include Helpers::Headers

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

end
