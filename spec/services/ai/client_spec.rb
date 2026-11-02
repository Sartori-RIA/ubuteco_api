# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ai::Client do
  let(:organization) { create(:organization, ai_enabled: true) }
  let(:admin) { organization.user }

  around do |example|
    previous = {
      'AI_ENABLED' => ENV['AI_ENABLED'],
      'AI_RATE_LIMIT_PER_MINUTE' => ENV['AI_RATE_LIMIT_PER_MINUTE'],
      'AI_RATE_LIMIT_PER_DAY' => ENV['AI_RATE_LIMIT_PER_DAY']
    }
    ENV['AI_ENABLED'] = '1'
    ENV['AI_RATE_LIMIT_PER_MINUTE'] = '2'
    ENV['AI_RATE_LIMIT_PER_DAY'] = '20'
    example.run
  ensure
    previous.each { |key, value| ENV[key] = value }
    clear_rate_keys
  end

  before { clear_rate_keys }

  def perform_ai_call
    described_class.complete(
      feature: Ai::Feature::ASSISTANT,
      tier: :fast,
      system: 'You are a test.',
      messages: [{ role: 'user', content: 'Hello' }],
      organization:,
      user: admin
    )
  end

  it_behaves_like 'an AI feature gated by org opt-in'

  it 'returns the fake result and records usage when AI is on' do
    Ai::FakeClient.enqueue(Ai.result(text: 'Buy more IPA', input_tokens: 4, output_tokens: 6))

    result = perform_ai_call

    expect(result.text).to eq('Buy more IPA')
    event = AiUsageEvent.last
    expect(event.status).to eq('ok')
    expect(event.feature).to eq('assistant')
    expect(event.input_tokens).to eq(4)
    expect(event.output_tokens).to eq(6)
    expect(event.user).to eq(admin)
  end

  it 'records a provider failure and raises' do
    Ai::FakeClient.enqueue(Ai::ProviderError.new('timeout'))

    expect { perform_ai_call }.to raise_error(Ai::ProviderError, 'timeout')
    expect(AiUsageEvent.last.status).to eq('error')
  end

  it 'stops at the per-minute limit' do
    2.times { perform_ai_call }

    expect { perform_ai_call }.to raise_error(Ai::RateLimitedError)
    expect(AiUsageEvent.last.status).to eq('rate_limited')
  end

  it 'does not read Current.organization' do
    Current.reset

    expect(perform_ai_call.text).to eq('ok')
    expect(Current.organization).to be_nil
  end

  it 'rejects an unknown feature' do
    expect do
      described_class.complete(
        feature: 'made-up',
        tier: :fast,
        system: 's',
        messages: [],
        organization:
      )
    end.to raise_error(ArgumentError, /unknown AI feature/)
  end

  def clear_rate_keys
    keys = Ai::RateLimiter.redis.keys('ai:rl:*')
    Ai::RateLimiter.redis.del(*keys) if keys.any?
  end
end
