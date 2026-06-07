# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stock reservation limits', type: :model do
  let(:organization) { create(:organization) }

  it 'allows the first item and rejects the second when only one unit remains' do
    drink = create(:drink, organization: organization, quantity_stock: 1)
    first_order = create(:order, :open, organization: organization)
    second_order = create(:order, :open, organization: organization)
    params = {
      item: drink,
      item_id: drink.id,
      item_type: drink.model_name,
      quantity: 1
    }

    first_item = Orders::AddItem.call(order: first_order, params: params)
    second_item = Orders::AddItem.call(order: second_order, params: params)

    expect(first_item).to be_persisted
    expect(second_item).not_to be_persisted
    expect(second_item.errors.details[:quantity].first).to include(error: :insufficient_stock)
    expect(drink.reload.quantity_stock).to eq(0)
  end
end
