require 'rails_helper'

RSpec.describe Drink, type: :model do
  describe 'validates' do
    it {is_expected.to validate_presence_of(:name)}
    it {is_expected.to monetize(:price)}
    it {is_expected.to validate_presence_of(:quantity_stock)}
  end

  describe 'associations' do
    it {is_expected.to belong_to(:maker)}
    it {is_expected.to belong_to(:user)}
    it {is_expected.to have_many(:order_items)}
  end
end
