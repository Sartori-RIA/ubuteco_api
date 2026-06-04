# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orders::AddItem do
  let(:organization) { create(:organization) }
  let(:order) { create(:order, :open, organization: organization) }

  it "creates an order item and recalculates the order total" do
    drink = create(:drink, organization: organization, price: 5, quantity_stock: 10)

    item = described_class.call(
      order: order,
      params: { item: drink, item_id: drink.id, item_type: drink.model_name, quantity: 2 }
    )

    expect(item).to be_persisted
    expect(order.reload.total_cents).to eq(drink.price_cents * 2)
    expect(drink.reload.quantity_stock).to eq(8)
  end

  it "returns an invalid item when params are missing" do
    item = described_class.call(order: order, params: {})

    expect(item).not_to be_persisted
    expect(item.errors[:quantity]).to be_present
  end
end
