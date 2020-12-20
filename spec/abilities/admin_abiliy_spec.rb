require 'rails_helper'

RSpec.describe Abilities::AdminAbility, type: :ability do
  describe "abilities" do

    before :all do
      @organization = create :organization
      @admin = @organization.user
      @admin.update(organization: @organization)
    end

    subject { Abilities::AdminAbility.new(user: @admin, params: {}) }

    context "when is an public" do
      it { is_expected.to be_able_to(:create, User) }
      it { is_expected.to be_able_to(:manage, @admin) }
    end
  end
end
