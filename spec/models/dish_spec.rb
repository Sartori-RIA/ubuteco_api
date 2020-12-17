# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dish, type: :model do
  describe 'validates' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to monetize(:price) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:dish_ingredients) }
    it { is_expected.to have_many(:foods) }
    it { is_expected.to belong_to(:organization) }
  end

  describe '#to_json' do
    let!(:role) { create(:role_as_restaurant) }
    let!(:dish_json) do
      dish = create(:dish_with_ingredients)
      JSON.parse(dish.to_json)
    end

    context 'when has ingredients' do
      subject { dish_json }

      it { is_expected.to include('dish_ingredients') }

      context 'with food' do
        subject { dish_json['dish_ingredients'][0] }

        it { is_expected.to include('food')}
      end
    end
  end
end
