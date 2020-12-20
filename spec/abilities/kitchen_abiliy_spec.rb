require 'rails_helper'

RSpec.describe Abilities::KitchenAbility do
  describe "abilities" do
    before :all do
      @user = create :user_kitchen
    end

    subject { Abilities::KitchenAbility.new(user: @user, params: {}, controller_name: "") }

    context "when is an admin" do
      it { is_expected.to be_able_to(:manage, @user) }
    end
  end
end
