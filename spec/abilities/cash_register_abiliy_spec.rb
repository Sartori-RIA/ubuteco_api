require 'rails_helper'

RSpec.describe Abilities::CashRegisterAbility, type: :ability do
  describe "abilities" do
    before :all do
      @user = create :user_cash_register
    end

    subject { Abilities::CashRegisterAbility.new(user: @user, params: {}, controller_name: "") }

    context "when is an kitchen" do
      it {is_expected.to be_able_to(:manage, @user)}
    end
  end
end
