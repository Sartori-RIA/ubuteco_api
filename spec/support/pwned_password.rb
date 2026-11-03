# frozen_string_literal: true

require 'webmock'

# Groups that create users in before(:all) run before the per-example stub.
# This stays behind any example stub and survives WebMock.reset!.
WebMock::StubRegistry.instance.register_global_stub(:after_local_stubs) do |request|
  next unless request.uri.host == 'api.pwnedpasswords.com'

  { status: 200, body: '' }
end

RSpec.configure do |config|
  config.before do
    require 'pwned'
    allow_any_instance_of(Pwned::Password).to receive(:pwned_count).and_return(0)
  end
end
