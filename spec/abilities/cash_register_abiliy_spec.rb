require 'rails_helper'

RSpec.describe Abilities::CashRegisterAbility, type: :ability do
  describe "abilities" do

    before :all do
      @organization = create(:organization)
      @user = create(:user, :cash_register, organization: @organization)
      @order = create(:order, :with_items, organization: @organization, user: @user)
      @table = build(:table, organization: @organization)
      @wine = build(:wine, organization: @organization)
      @beer = build(:beer, organization: @organization)
      @dish = build(:dish, organization: @organization)
      @drink = build(:drink, organization: @organization)
      @food = build(:food, organization: @organization)
      @maker = build(:maker, organization: @organization)
      @customer = build(:user, :customer)
    end

    subject { described_class.new(user: @user, params: { order_id: @order.id }, controller_name: "Api::V1::Kitchens") }

    context "when is an cash register" do
      context 'can' do
        it { is_expected.to be_able_to(:read, @dish) }
        it { is_expected.to be_able_to(:read, @beer) }
        it { is_expected.to be_able_to(:read, @wine) }
        it { is_expected.to be_able_to(:read, @drink) }
        it { is_expected.to be_able_to(:read, @food) }
        it { is_expected.to be_able_to(:create, @order) }
        it { is_expected.to be_able_to(:read, @order) }
        it { is_expected.to be_able_to(:update, @order) }
        it { is_expected.to be_able_to(:destroy, @order) }
        it { is_expected.to be_able_to(:read, @order.order_items.sample) }
        it { is_expected.to be_able_to(:create, @order.order_items.sample) }
        it { is_expected.to be_able_to(:update, @order.order_items.sample) }
        it { is_expected.to be_able_to(:destroy, @order.order_items.sample) }
        context 'in users controller' do
          subject { described_class.new(user: @user, params: { order_id: @order.id }, controller_name: "Api::V1::Users") }
          it { is_expected.to be_able_to(:read, @user) }
          it { is_expected.to be_able_to(:update, @user) }
        end
        context 'in customers controller' do
          subject { described_class.new(user: @user, params: { order_id: @order.id }, controller_name: "Api::V1::Customers") }
          it { is_expected.to be_able_to(:read, @customer) }
        end
      end
    end
  end
end
