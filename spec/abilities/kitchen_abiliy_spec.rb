require 'rails_helper'

RSpec.describe Abilities::KitchenAbility, type: :ability do
  describe "abilities" do

    let(:organization) { create(:organization) }
    let(:user) { create(:user_kitchen, organization: organization) }
    let(:order) { create(:order, :with_dish, organization: organization) }

    subject { Abilities::KitchenAbility.new(user: user, controller_name: 'Api::Kitchens') }

    context "when is an kitchen" do
      context 'can' do
        it { is_expected.to be_able_to(:manage, user) }
        it { is_expected.to be_able_to(:read, order.order_items.sample) }
        it { is_expected.to be_able_to(:update, order.order_items.sample) }
        context 'in users controller' do
          subject { Abilities::KitchenAbility.new(user: user, controller_name: "Api::Users") }
          it { is_expected.to be_able_to(:read, user) }
          it { is_expected.to be_able_to(:update, user) }
        end
      end
    end
  end
end
