# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organizations::Dashboard::Series do
  let(:organization) { create(:organization, timezone: 'America/Sao_Paulo') }
  let(:from) { '2026-05-20' }
  let(:to) { '2026-05-22' }

  before do
    create(:order, :closed, organization:, total_cents: 1000, created_at: Time.utc(2026, 5, 20, 10))
    create(:order, :closed, organization:, total_cents: 2000, created_at: Time.utc(2026, 5, 22, 10))
  end

  it 'returns daily revenue buckets with zero-filled gaps' do
    result = described_class.call(org: organization, from:, to:, metric: 'revenue')

    expect(result[:points]).to eq([
                                  { date: '2026-05-20', value: 1000 },
                                  { date: '2026-05-21', value: 0 },
                                  { date: '2026-05-22', value: 2000 }
                                ])
  end
end
