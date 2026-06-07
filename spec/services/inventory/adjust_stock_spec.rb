# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inventory::AdjustStock do
  let(:organization) { create(:organization) }
  let(:drink) { create(:drink, organization: organization, quantity_stock: 10) }

  it 'increments stock by a positive adjustment' do
    expect(
      described_class.call(product: drink, adjustment: 5, reason: 'delivery')
    ).to be(true)

    expect(drink.reload.quantity_stock).to eq(15)
  end

  it 'decrements stock by a negative adjustment' do
    expect(
      described_class.call(product: drink, adjustment: -3, reason: 'waste')
    ).to be(true)

    expect(drink.reload.quantity_stock).to eq(7)
  end

  it 'rejects adjustments that would make stock negative' do
    expect(
      described_class.call(product: drink, adjustment: -11)
    ).to be(false)

    expect(drink.reload.quantity_stock).to eq(10)
    expect(drink.errors[:quantity_stock]).to be_present
  end

  it 'rejects zero adjustments' do
    expect(
      described_class.call(product: drink, adjustment: 0)
    ).to be(false)

    expect(drink.errors[:adjustment]).to be_present
  end

  it 'rejects non-stockable products' do
    dish = create(:dish, organization: organization)

    expect(
      described_class.call(product: dish, adjustment: 1)
    ).to be(false)

    expect(dish.errors[:base]).to be_present
  end
end
