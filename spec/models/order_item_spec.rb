# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'currency validation' do
    it 'rejects items priced in a different currency than the order' do
      organization = create(:organization)
      order = create(:order, organization: organization)
      beer = create(:beer, organization: organization, maker: create(:maker, organization: organization))
      beer.update_column(:price_currency, 'USD')

      item = build(:order_item, order: order, item: beer)

      expect(item).not_to be_valid
      expect(item.errors.details[:item].first).to include(error: :currency_mismatch)
    end

    it 'accepts items when currency matches the order' do
      organization = create(:organization, :usd)
      order = create(:order, organization: organization)
      beer = create(:beer, organization: organization, maker: create(:maker, organization: organization))
      beer.update_columns(price_currency: 'USD')

      item = build(:order_item, order: order, item: beer)

      expect(item).to be_valid
    end
  end
end
