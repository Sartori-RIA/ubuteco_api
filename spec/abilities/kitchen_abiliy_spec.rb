require 'rails_helper'

RSpec.describe Abilities::KitchenAbility, type: :ability do
  describe "abilities" do
    before :all do
      @user = create :user_kitchen
    end

    subject { Abilities::KitchenAbility.new(user: @user, controller_name: "") }

    context "when is an kitchen" do
      context 'can' do
        it { is_expected.to be_able_to(:manage, @user) }
        it { is_expected.to be_able_to(:read, OrderItem.new) }
        it { is_expected.to be_able_to(:update, OrderItem.new) }
      end
    end
  end
end
