require 'rspec-sidekiq'

RSpec.configure do |config|
  config.before(:suite) do
    Searchkick.disable_callbacks
  end
end