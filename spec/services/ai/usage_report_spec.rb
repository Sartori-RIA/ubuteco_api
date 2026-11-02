# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ai::UsageReport do
  let(:organization) { create(:organization, name: 'Bar') }

  it 'totals calls and tokens per organization, feature, and day' do
    travel_to Time.zone.parse('2026-11-02 15:00:00') do
      AiUsageEvent.create!(
        organization:, feature: 'assistant', status: 'ok',
        input_tokens: 10, output_tokens: 4, model: 'claude-haiku-5-5'
      )
      AiUsageEvent.create!(
        organization:, feature: 'assistant', status: 'error',
        input_tokens: 2, output_tokens: 0, model: 'claude-haiku-5-5'
      )
    end

    rows = described_class.call(from: Date.new(2026, 11, 2), to: Date.new(2026, 11, 2))

    expect(rows.size).to eq(1)
    expect(rows.first.organization_name).to eq('Bar')
    expect(rows.first.calls).to eq(2)
    expect(rows.first.input_tokens).to eq(12)
    expect(rows.first.output_tokens).to eq(4)
    expect(rows.first.failed_calls).to eq(1)
  end
end
