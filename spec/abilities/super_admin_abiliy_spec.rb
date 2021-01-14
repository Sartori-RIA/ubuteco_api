require 'rails_helper'

RSpec.describe Abilities::SuperAdminAbility, type: :ability do
  describe "abilities" do

    subject { Abilities::SuperAdminAbility.new user: create(:user) }

    context "when is an admin" do
      it { is_expected.to be_able_to(:manage, Beer.new) }
    end
  end
end
