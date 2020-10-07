require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    it {is_expected.to monetize(:total)}
    it {is_expected.to monetize(:discount)}
    it {is_expected.to monetize(:total_with_discount)}
  end

  describe 'associations' do
    it {is_expected.to belong_to(:user)}
    it {is_expected.to belong_to(:table)}
    it {is_expected.to have_many(:order_items)}
  end
end
