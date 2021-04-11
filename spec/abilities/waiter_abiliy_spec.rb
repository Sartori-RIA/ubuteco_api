require 'rails_helper'

RSpec.describe Abilities::WaiterAbility, type: :ability do
  describe "abilities" do
    before :each do
      @organization = create(:organization)
      @admin = @organization.user
      @user = create(:user_waiter, organization: @organization)
      @order = create(:order, :open, :with_items, organization: @organization)
      @table = create(:table, organization: @organization)
      @wine = create(:wine, organization: @organization)
      @beer = create(:beer, organization: @organization)
      @dish = create(:dish, organization: @organization)
      @drink = create(:drink, organization: @organization)
      @food = create(:food, organization: @organization)
      @maker = create(:maker, organization: @organization)
    end


    subject { Abilities::WaiterAbility.new(user: @user, params: { order_id: @order.id }, controller_name: 'Api::V1::Kitchens') }

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
          subject { Abilities::WaiterAbility.new(user: @user, params: { order_id: @order.id }, controller_name: "Api::V1::Users") }
          it { is_expected.to be_able_to(:read, @user) }
        end
      end
    end
  end
end
