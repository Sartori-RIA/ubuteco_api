# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  let(:organization) { create(:organization) }
  let(:waiter) { create(:user, :waiter, organization: organization) }
  let(:order) { create(:order, :open, organization: organization, user: waiter) }
  describe 'stock adjustments' do
    it 'decrements drink stock when an item is created' do
      drink = create(:drink, organization: organization, quantity_stock: 10)

      create(:order_item, order: order, item: drink, quantity: 3)

      expect(drink.reload.quantity_stock).to eq(7)
    end

    it 'restores stock when an item is destroyed' do
      drink = create(:drink, organization: organization, quantity_stock: 10)
      item = create(:order_item, order: order, item: drink, quantity: 3)

      item.destroy!

      expect(drink.reload.quantity_stock).to eq(10)
    end

    it 'rejects creation when stock is insufficient' do
      drink = create(:drink, organization: organization, quantity_stock: 2)

      item = build(:order_item, order: order, item: drink, quantity: 5)

      expect(item.save).to be false
      expect(drink.reload.quantity_stock).to eq(2)
    end

    it 'adjusts stock when quantity changes' do
      drink = create(:drink, organization: organization, quantity_stock: 10)
      item = create(:order_item, order: order, item: drink, quantity: 2)
      expect(drink.reload.quantity_stock).to eq(8)

      previous_quantity = item.quantity
      item.update!(quantity: 5)
      item.apply_quantity_change!(previous_quantity:)

      expect(drink.reload.quantity_stock).to eq(5)
    end
  end
end
