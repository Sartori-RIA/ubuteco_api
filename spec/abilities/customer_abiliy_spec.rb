require 'rails_helper'

RSpec.describe Abilities::CustomerAbility, type: :ability do
  describe "abilities" do

    let(:organization) { create(:organization) }
    let(:user) { create :user_customer }
    let(:order) { create(:order, :with_items, organization: organization, user: user) }

    subject { Abilities::CustomerAbility.new(user: user, params: { order_id: order.id }, controller_name: 'Api::Users') }

    context "when is an customer" do
      context 'can' do
        it { is_expected.to be_able_to(:manage, user) }
        it { is_expected.to be_able_to(:read, Beer.new) }
        it { is_expected.to be_able_to(:read, Dish.new) }
        it { is_expected.to be_able_to(:read, Drink.new) }
        it { is_expected.to be_able_to(:read, Food.new) }
        it { is_expected.to be_able_to(:read, Maker.new) }
        it { is_expected.to be_able_to(:read, Table.new) }
        it { is_expected.to be_able_to(:read, Wine.new) }
        it { is_expected.to be_able_to(:create, order) }
        it { is_expected.to be_able_to(:read, order) }
        it { is_expected.to be_able_to(:update, order) }
        it { is_expected.to be_able_to(:destroy, order) }
        it { is_expected.to be_able_to(:read, order.order_items.sample) }
        it { is_expected.to be_able_to(:update, order.order_items.sample) }
        it { is_expected.to be_able_to(:create, order.order_items.sample) }
        it { is_expected.to be_able_to(:edit, order.order_items.sample) }
        it { is_expected.to be_able_to(:destroy, order.order_items.sample) }
        context 'in users controller' do
          subject { Abilities::CustomerAbility.new(user: user, params: { order_id: order.id }, controller_name: "Api::Users") }
          it { is_expected.to be_able_to(:read, user) }
          it { is_expected.to be_able_to(:update, user) }
        end
      end
    end
  end
end
