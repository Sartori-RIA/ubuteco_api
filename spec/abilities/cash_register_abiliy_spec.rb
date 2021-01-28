require 'rails_helper'

RSpec.describe Abilities::CashRegisterAbility, type: :ability do
  describe "abilities" do
    before :all do
      @user = create :user_cash_register
    end

    subject { Abilities::CashRegisterAbility.new(user: @user, params: {}, controller_name: "") }

    context "when is an cash register" do
      context 'can' do
        it { is_expected.to be_able_to(:read, @user) }
        it { is_expected.to be_able_to(:update, @user) }
        it { is_expected.to be_able_to(:read, Dish.new) }
        it { is_expected.to be_able_to(:update, Dish.new) }
        it { is_expected.to be_able_to(:read, Beer.new) }
        it { is_expected.to be_able_to(:update, Beer.new) }
        it { is_expected.to be_able_to(:read, Wine.new) }
        it { is_expected.to be_able_to(:update, Wine.new) }
        it { is_expected.to be_able_to(:read, Drink.new) }
        it { is_expected.to be_able_to(:update, Drink.new) }
        it { is_expected.to be_able_to(:read, Food.new) }
        it { is_expected.to be_able_to(:update, Food.new) }
        it { is_expected.to be_able_to(:manage, Order.new) }
        it { is_expected.to be_able_to(:manage, OrderItem.new) }
      end
    end
  end
end
