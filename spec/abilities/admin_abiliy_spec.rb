require 'rails_helper'

RSpec.describe Abilities::AdminAbility, type: :ability do
  describe "abilities" do
    let!(:organization) { create(:organization) }
    let!(:admin) do
      organization.user.update(organization: organization)
      organization.user
    end

    let!(:order) { create(:order, :open, :with_items, organization: organization) }
    let!(:table) { create(:table, organization: organization) }
    let!(:wine) { create(:wine, organization: organization) }
    let!(:beer) { create(:beer, organization: organization) }
    let!(:drink) { create(:drink, organization: organization) }
    let!(:food) { create(:food, organization: organization) }
    let!(:maker) { create(:maker, organization: organization) }
    let!(:dish) { create(:dish, organization: organization) }
    let!(:user) { create(:user, organization: organization) }
    let!(:dish_ingredient) { create(:dish_ingredient, food: food, dish: dish) }

    subject { Abilities::AdminAbility.new(user: admin, params: { id: order.id }) }

    context "when is an admin" do
      context 'can' do
        it { is_expected.to be_able_to(:manage, user) }
        it { is_expected.to be_able_to(:manage, admin) }
        it { is_expected.to be_able_to(:read, organization.theme) }
        it { is_expected.to be_able_to(:update, organization.theme) }
        it { is_expected.to be_able_to(:manage, organization) }
        it { is_expected.to be_able_to(:manage, beer) }
        it { is_expected.to be_able_to(:manage, dish_ingredient) }
        it { is_expected.to be_able_to(:manage, dish) }
        it { is_expected.to be_able_to(:manage, drink) }
        it { is_expected.to be_able_to(:manage, food) }
        it { is_expected.to be_able_to(:manage, maker) }
        it { is_expected.to be_able_to(:manage, table) }
        it { is_expected.to be_able_to(:manage, wine) }
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
