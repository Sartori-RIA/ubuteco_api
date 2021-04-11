require 'rails_helper'

RSpec.describe Abilities::KitchenAbility, type: :ability do
  describe "abilities" do

    before :all do
      @organization = create(:organization)
      @user = create(:user_kitchen, organization: @organization)
      @order = create(:order, :with_dish, organization: @organization)
    end

    subject { Abilities::KitchenAbility.new(user: @user, controller_name: 'Api::V1::Kitchens') }

    context "when is an kitchen" do
      context 'can' do
        it { is_expected.to be_able_to(:manage, @user) }
        it { is_expected.to be_able_to(:read, @order.order_items.sample) }
        it { is_expected.to be_able_to(:update, @order.order_items.sample) }
        context 'in users controller' do
          subject { Abilities::KitchenAbility.new(user: @user, controller_name: "Api::V1::Users") }
          it { is_expected.to be_able_to(:read, @user) }
          it { is_expected.to be_able_to(:update, @user) }
        end
      end
    end
  end
end
