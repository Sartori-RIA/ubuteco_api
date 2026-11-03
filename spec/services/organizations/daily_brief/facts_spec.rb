# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organizations::DailyBrief::Facts do
  let(:zone) { Time.find_zone!('America/Sao_Paulo') }
  let(:organization) { create(:organization, timezone: 'America/Sao_Paulo', locale: 'pt-BR', default_currency: 'BRL') }

  def paid_order(at:, cents:)
    order = create(:order, organization:, status: :open, created_at: at)
    order.update_columns(status: Order.statuses[:payed], total_cents: cents, created_at: at)
    order
  end

  it 'uses the organization calendar day at 00:30 local' do
    travel_to(zone.local(2026, 11, 2, 0, 30)) do
      paid_order(at: zone.local(2026, 11, 1, 23, 0), cents: 15_000)
      paid_order(at: zone.local(2026, 11, 2, 0, 10), cents: 5_000)
      paid_order(at: zone.local(2026, 10, 25, 12, 0), cents: 10_000)
      create(:beer, organization:, name: 'Low IPA', quantity_stock: 1)
      create(:food, organization:, name: 'Bread', valid_until: zone.local(2026, 11, 3, 12, 0))

      facts = described_class.call(organization:)

      expect(facts[:yesterday]).to eq('2026-11-01')
      expect(facts[:yesterday_orders]).to eq(1)
      expect(facts[:today_orders]).to eq(1)
      expect(facts[:revenue_delta_percent]).to eq(50)
      expect(facts[:low_stock_names]).to include('Low IPA')
      expect(facts[:expiring_names]).to include('Bread')
    end
  end

  it 'keeps yesterday on the Toronto calendar at 00:30 local' do
    toronto = Time.find_zone!('America/Toronto')
    organization.update!(timezone: 'America/Toronto')

    travel_to(toronto.local(2026, 11, 2, 0, 30)) do
      paid_order(at: toronto.local(2026, 11, 1, 23, 0), cents: 4_000)

      facts = described_class.call(organization:)

      expect(facts[:yesterday]).to eq('2026-11-01')
      expect(facts[:yesterday_orders]).to eq(1)
      expect(facts[:today_orders]).to eq(0)
    end
  end
end
