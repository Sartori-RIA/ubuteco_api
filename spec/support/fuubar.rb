# frozen_string_literal: true

RSpec.configure do |config|
  config.add_formatter 'Fuubar'
  config.fuubar_auto_refresh = true
  config.color = true
end
