# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ai::RateLimiter do
  let(:organization) { create(:organization) }
  let(:limiter) { described_class.new }

  around do |example|
    previous = ENV['AI_RATE_LIMIT_PER_MINUTE']
    ENV['AI_RATE_LIMIT_PER_MINUTE'] = '2'
    example.run
  ensure
    ENV['AI_RATE_LIMIT_PER_MINUTE'] = previous
    clear_rate_keys
  end

  before { clear_rate_keys }

  it 'allows N calls and refuses N+1 inside the same minute' do
    travel_to Time.zone.parse('2026-11-02 12:00:00') do
      expect(limiter.allow?(organization:, feature: 'assistant')).to be(true)
      expect(limiter.allow?(organization:, feature: 'assistant')).to be(true)
      expect(limiter.allow?(organization:, feature: 'assistant')).to be(false)
    end
  end

  def clear_rate_keys
    keys = described_class.redis.keys('ai:rl:*')
    described_class.redis.del(*keys) if keys.any?
  end
end
