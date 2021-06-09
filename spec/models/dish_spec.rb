# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dish, type: :model do
  describe 'validates' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to monetize(:price) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:dish_ingredients) }
    it { is_expected.to have_many(:foods).through(:dish_ingredients) }
    it { is_expected.to belong_to(:organization) }
  end
end
