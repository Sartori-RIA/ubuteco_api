require 'rails_helper'

RSpec.describe Abilities::WaiterAbility, type: :ability do
  describe "abilities" do
    let!(:organization) { create(:organization) }
    let!(:admin) do
      organization.user.update(organization: organization)
      organization.user
    end
    let!(:waiter) { create(:user_waiter, organization: organization) }
    let!(:order) { create(:order, :open, :with_items, organization: organization) }
    let!(:table) { create(:table, organization: organization) }
    let!(:wine) { create(:wine, organization: organization) }
    let!(:beer) { create(:beer, organization: organization) }
    let!(:dish) { create(:dish, organization: organization) }
    let!(:drink) { create(:drink, organization: organization) }
    let!(:food) { create(:food, organization: organization) }
    let!(:maker) { create(:maker, organization: organization) }

    subject { Abilities::WaiterAbility.new(user: waiter, params: { order_id: order.id }) }

    context "when is an waiter" do
      context 'can' do
        it { is_expected.to be_able_to(:manage, waiter) }
        it { is_expected.to be_able_to(:read, table) }
        it { is_expected.to be_able_to(:search, table) }
        it { is_expected.to be_able_to(:read, wine) }
        it { is_expected.to be_able_to(:search, wine) }
        it { is_expected.to be_able_to(:read, beer) }
        it { is_expected.to be_able_to(:search, beer) }
        it { is_expected.to be_able_to(:read, dish) }
        it { is_expected.to be_able_to(:search, dish) }
        it { is_expected.to be_able_to(:read, drink) }
        it { is_expected.to be_able_to(:search, drink) }
        it { is_expected.to be_able_to(:read, food) }
        it { is_expected.to be_able_to(:search, food) }
        it { is_expected.to be_able_to(:read, maker) }
        it { is_expected.to be_able_to(:search, maker) }
        it { is_expected.to be_able_to(:create, order) }
        it { is_expected.to be_able_to(:read, order) }
        it { is_expected.to be_able_to(:search, order) }
        it { is_expected.to be_able_to(:update, order) }
        it { is_expected.to be_able_to(:destroy, order) }
        it { is_expected.to be_able_to(:read, order.order_items.sample) }
        it { is_expected.to be_able_to(:search, order.order_items.sample) }
        it { is_expected.to be_able_to(:create, order.order_items.sample) }
        it { is_expected.to be_able_to(:update, order.order_items.sample) }
        it { is_expected.to be_able_to(:destroy, order.order_items.sample) }
      end
    end
  end
end
