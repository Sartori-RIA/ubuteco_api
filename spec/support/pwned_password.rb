# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    next unless defined?(Pwned::Password)

    allow_any_instance_of(Pwned::Password).to receive(:pwned_count).and_return(0)
  end
end
