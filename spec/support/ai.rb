# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    Ai::FakeClient.reset!
  end
end

RSpec.shared_examples 'an AI feature gated by org opt-in' do
  it 'refuses the call when the organization has not opted in' do
    organization.update!(ai_enabled: false)

    expect { perform_ai_call }.to raise_error(Ai::DisabledError)
    expect(AiUsageEvent.last.status).to eq('disabled')
  end
end
