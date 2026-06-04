# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orders::RemoveItem do
  let(:organization) { create(:organization) }
  let(:order) { create(:order, :open, organization: organization) }

  it "destroys the item and restores stock" do
    drink = create(:drink, organization: organization, quantity_stock: 10)
    item = create(:order_item, order: order, item: drink, quantity: 3)

    expect(described_class.call(order_item: item)).to be true
    expect(OrderItem.exists?(item.id)).to be false
    expect(drink.reload.quantity_stock).to eq(10)
  end
end
