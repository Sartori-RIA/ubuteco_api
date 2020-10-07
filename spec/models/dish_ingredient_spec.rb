require 'rails_helper'

RSpec.describe DishIngredient, type: :model do
  describe 'validates' do
    it {is_expected.to validate_presence_of(:quantity)}
  end

  describe 'associations' do
    it {is_expected.to belong_to(:food)}
    it {is_expected.to belong_to(:dish)}
  end
end
