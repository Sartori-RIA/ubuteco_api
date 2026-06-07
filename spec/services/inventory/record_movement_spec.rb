# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inventory::RecordMovement do
  let(:organization) { create(:organization) }
  let(:drink) { create(:drink, organization: organization, quantity_stock: 10) }
  let(:admin) { organization.user }

  it 'creates a movement for manual adjustments' do
    movement = described_class.call(
      organization: organization,
      product: drink,
      delta: 5,
      reason: 'delivery',
      user: admin
    )

    expect(movement).to be_persisted
    expect(movement).to have_attributes(
      delta: 5,
      reason: 'delivery',
      user: admin,
      order_item: nil
    )
  end

  it 'skips non-stockable products' do
    dish = create(:dish, organization: organization)

    expect(
      described_class.call(organization: organization, product: dish, delta: 1)
    ).to be_nil
  end
end
