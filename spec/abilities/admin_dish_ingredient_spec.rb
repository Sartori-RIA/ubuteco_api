# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Abilities::AdminAbility, type: :ability do
  describe 'dish ingredient scope' do
    let(:organization) { create(:organization) }
    let(:admin) { organization.user }
    let(:dish) { create(:dish, organization: organization) }
    let(:food) { create(:food, organization: organization) }
    let(:ingredient) { create(:dish_ingredient, dish: dish, food: food) }
    let(:foreign_ingredient) do
      foreign_org = create(:organization)
      foreign_dish = create(:dish, organization: foreign_org)
      foreign_food = create(:food, organization: foreign_org)
      create(:dish_ingredient, dish: foreign_dish, food: foreign_food)
    end

    subject do
      described_class.new(
        user: admin,
        params: {},
        controller_name: 'Api::V1::Dishes::Ingredients'
      )
    end

    it { is_expected.to be_able_to(:manage, ingredient) }
    it { is_expected.not_to be_able_to(:manage, foreign_ingredient) }
  end
end
