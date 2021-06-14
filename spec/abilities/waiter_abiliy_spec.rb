require 'rails_helper'

RSpec.describe Abilities::WaiterAbility, type: :ability do
  describe "abilities" do
    before :all do
      @organization = create(:organization)
      @admin = @organization.user
      @user = create(:user, :waiter, organization: @organization)
      @order = create(:order, :open, :with_items, organization: @organization)
      @table = build(:table, organization: @organization)
      @wine = build(:wine, organization: @organization)
      @beer = build(:beer, organization: @organization)
      @dish = build(:dish, organization: @organization)
      @drink = build(:drink, organization: @organization)
      @food = build(:food, organization: @organization)
      @maker = build(:maker, organization: @organization)
    end

    subject { described_class.new(user: @user, params: { order_id: @order.id }, controller_name: 'Api::V1::Kitchens') }

    context "when is an waiter" do
      context 'can' do
        it { is_expected.to be_able_to(:read, @table) }
        it { is_expected.to be_able_to(:read, @wine) }
        it { is_expected.to be_able_to(:read, @beer) }
        it { is_expected.to be_able_to(:read, @dish) }
        it { is_expected.to be_able_to(:read, @drink) }
        it { is_expected.to be_able_to(:read, @food) }
        it { is_expected.to be_able_to(:read, @maker) }
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
        end
      end
    end
  end
end
