require 'rails_helper'

RSpec.describe Abilities::CustomerAbility do
  describe "abilities" do
    before :all do
      @user = create :user_customer
    end

    subject { Abilities::CustomerAbility.new(user: @user) }

    context "when is an admin" do
      it {is_expected.to be_able_to(:manage, @user)}
    end
  end
end
