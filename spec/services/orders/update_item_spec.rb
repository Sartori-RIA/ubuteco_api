# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orders::UpdateItem do
  let(:organization) { create(:organization) }
  let(:order) { create(:order, :open, organization: organization) }

  it "updates quantity and adjusts stock" do
    drink = create(:drink, organization: organization, quantity_stock: 10)
    item = create(:order_item, order: order, item: drink, quantity: 2)

    result = described_class.call(order_item: item, params: { quantity: 4 })

    expect(result.errors).to be_empty
    expect(drink.reload.quantity_stock).to eq(6)
  end

  it "returns errors for invalid status transitions" do
    dish = create(:dish, organization: organization)
    item = create(:order_item, order: order, item: dish, status: :awaiting)

    result = described_class.call(order_item: item, params: { status: "ready" })

    expect(result.errors[:status]).to be_present
  end
end
