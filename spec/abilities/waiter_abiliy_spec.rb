require 'rails_helper'

RSpec.describe Abilities::WaiterAbility, type: :ability do
  describe "abilities" do
    before :all do
      @user = create :user_waiter
    end

    subject { Abilities::WaiterAbility.new(user: @user) }

    context "when is an admin" do
      it {is_expected.to be_able_to(:manage, @user)}
    end
  end
end
