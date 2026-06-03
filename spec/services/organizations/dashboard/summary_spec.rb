# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organizations::Dashboard::Summary do
  let(:organization) { create(:organization, timezone: 'America/Sao_Paulo', default_currency: 'BRL') }
  let(:from) { '2026-05-20' }
  let(:to) { '2026-05-26' }

  around do |example|
    travel_to Time.utc(2026, 5, 26, 15, 0, 0) { example.run }
  end

  before do
    create(:order, :open, organization:, total_cents: 5000, created_at: Time.utc(2026, 5, 21, 12))
    create(:order, :closed, organization:, total_cents: 10_000, created_at: Time.utc(2026, 5, 22, 12))
    create(:order, :payed, organization:, total_cents: 20_000, created_at: Time.utc(2026, 5, 23, 12))
    create(:order, :closed, organization:, total_cents: 99_000, created_at: Time.utc(2026, 5, 10, 12))
  end

  it 'returns KPIs for completed orders in range' do
    result = described_class.call(org: organization, from:, to:)

    expect(result[:revenue_cents]).to eq(30_000)
    expect(result[:orders_count]).to eq(3)
    expect(result[:open_orders_count]).to eq(1)
    expect(result[:average_ticket_cents]).to eq(15_000)
    expect(result[:currency]).to eq('BRL')
  end
end
