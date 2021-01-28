require 'rails_helper'

RSpec.describe Abilities::WaiterAbility, type: :ability do
  describe "abilities" do
    before :all do
      @user = create :user_waiter
    end

    subject { Abilities::WaiterAbility.new(user: @user, params: {}) }

    context "when is an waiter" do
      context 'can' do
        it { is_expected.to be_able_to(:manage, @user) }
        it { is_expected.to be_able_to(:read, Table.new) }
        it { is_expected.to be_able_to(:search, Table.new) }
        it { is_expected.to be_able_to(:read, Wine.new) }
        it { is_expected.to be_able_to(:search, Wine.new) }
        it { is_expected.to be_able_to(:read, Beer.new) }
        it { is_expected.to be_able_to(:search, Beer.new) }
        it { is_expected.to be_able_to(:read, Dish.new) }
        it { is_expected.to be_able_to(:search, Dish.new) }
        it { is_expected.to be_able_to(:read, Drink.new) }
        it { is_expected.to be_able_to(:search, Drink.new) }
        it { is_expected.to be_able_to(:read, Food.new) }
        it { is_expected.to be_able_to(:search, Food.new) }
        it { is_expected.to be_able_to(:read, Maker.new) }
        it { is_expected.to be_able_to(:search, Maker.new) }
        it { is_expected.to be_able_to(:manage, Order.new) }
      end
    end
  end
end
