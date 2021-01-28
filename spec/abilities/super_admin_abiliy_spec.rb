require 'rails_helper'

RSpec.describe Abilities::SuperAdminAbility, type: :ability do
  describe "abilities" do

    subject { Abilities::SuperAdminAbility.new user: create(:user), params: {} }

    context "when is an super admin" do
      context 'can' do
        it { is_expected.to be_able_to(:manage, Beer.new) }
        it { is_expected.to be_able_to(:manage, Role.new) }
        it { is_expected.to be_able_to(:read, Theme.new) }
        it { is_expected.to be_able_to(:update, Theme.new) }
        it { is_expected.to be_able_to(:manage, User.new) }
        it { is_expected.to be_able_to(:manage, Wine.new) }
        it { is_expected.to be_able_to(:manage, WineStyle.new) }
        it { is_expected.to be_able_to(:manage, BeerStyle.new) }
        it { is_expected.to be_able_to(:manage, Dish.new) }
        it { is_expected.to be_able_to(:manage, DishIngredient.new) }
        it { is_expected.to be_able_to(:manage, Drink.new) }
        it { is_expected.to be_able_to(:manage, Food.new) }
        it { is_expected.to be_able_to(:manage, Maker.new) }
        it { is_expected.to be_able_to(:manage, Table.new) }
        it { is_expected.to be_able_to(:manage, Order.new) }
        it { is_expected.to be_able_to(:manage, OrderItem.new) }
      end
    end
  end
end
