require 'rails_helper'

RSpec.describe Abilities::CashRegisterAbility, type: :ability do
  describe "abilities" do

    let!(:organization) { create(:organization) }
    let!(:user) { create(:user_cash_register, organization: organization) }
    let!(:order) { create(:order, :with_items, organization: organization, user: user) }
    let!(:table) { create(:table, organization: organization) }
    let!(:wine) { create(:wine, organization: organization) }
    let!(:beer) { create(:beer, organization: organization) }
    let!(:dish) { create(:dish, organization: organization) }
    let!(:drink) { create(:drink, organization: organization) }
    let!(:food) { create(:food, organization: organization) }
    let!(:maker) { create(:maker, organization: organization) }
    let!(:customer) { create(:user_customer) }

    subject { Abilities::CashRegisterAbility.new(user: user, params: { order_id: order.id }, controller_name: "Api::V1::Kitchens") }

    context "when is an cash register" do
      context 'can' do
        it { is_expected.to be_able_to(:read, dish) }
        it { is_expected.to be_able_to(:read, beer) }
        it { is_expected.to be_able_to(:read, wine) }
        it { is_expected.to be_able_to(:read, drink) }
        it { is_expected.to be_able_to(:read, food) }
        it { is_expected.to be_able_to(:create, order) }
        it { is_expected.to be_able_to(:read, order) }
        it { is_expected.to be_able_to(:update, order) }
        it { is_expected.to be_able_to(:destroy, order) }
        it { is_expected.to be_able_to(:read, order.order_items.sample) }
        it { is_expected.to be_able_to(:create, order.order_items.sample) }
        it { is_expected.to be_able_to(:update, order.order_items.sample) }
        it { is_expected.to be_able_to(:destroy, order.order_items.sample) }
        context 'in users controller' do
          subject { Abilities::CashRegisterAbility.new(user: user, params: { order_id: order.id }, controller_name: "Api::V1::Users") }
          it { is_expected.to be_able_to(:read, user) }
          it { is_expected.to be_able_to(:update, user) }
        end
        context 'in customers controller' do
          subject { Abilities::CashRegisterAbility.new(user: user, params: { order_id: order.id }, controller_name: "Api::V1::Customers") }
          it { is_expected.to be_able_to(:read, customer) }
        end
      end
    end
  end
end
