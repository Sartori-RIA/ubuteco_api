# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organizations::Dashboard::Kitchen do
  let(:organization) { create(:organization) }
  let(:from) { '2026-05-20' }
  let(:to) { '2026-05-26' }

  before do
    open_order = create(:order, :open, organization:)
    dish = create(:dish, organization:)
    create(
      :order_item,
      :with_dish,
      order: open_order,
      item: dish,
      status: :awaiting,
      created_at: 1.hour.ago,
      updated_at: 1.hour.ago
    )

    closed_order = create(:order, :open, organization:)
    ready_dish = create(:dish, organization:)
    create(
      :order_item,
      order: closed_order,
      item: ready_dish,
      quantity: 1,
      status: :ready,
      created_at: Time.utc(2026, 5, 22, 12, 0, 0),
      updated_at: Time.utc(2026, 5, 22, 12, 10, 0)
    )
    closed_order.update_column(:status, Order.statuses[:closed])
  end

  it 'returns open dish count and average prep seconds' do
    result = described_class.call(org: organization, from:, to:)

    expect(result[:open_dish_count]).to eq(1)
    expect(result[:avg_prep_seconds]).to eq(600)
  end
end
