require 'rails_helper'

RSpec.describe Abilities::SuperAdminAbility do
  describe "abilities" do

    subject { Abilities::SuperAdminAbility.new }

    context "when is an admin" do
      it {is_expected.to be_able_to(:manage, Beer.new)}
    end
  end
end
