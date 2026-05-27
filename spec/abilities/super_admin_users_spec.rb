# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Abilities::SuperAdminAbility, type: :ability do
  let(:organization) { create(:organization) }
  let(:super_admin) { create(:user, :super_admin) }
  let(:org_user) { create(:user, organization: organization) }

  describe 'users permissions' do
    it 'allows read-only access on the global users controller' do
      ability = described_class.new(
        user: super_admin,
        params: {},
        controller_name: 'Api::V1::Users'
      )

      expect(ability).to be_able_to(:read, org_user)
      expect(ability).not_to be_able_to(:manage, org_user)
      expect(ability).not_to be_able_to(:update, org_user)
      expect(ability).not_to be_able_to(:destroy, org_user)
    end

    it 'allows managing users scoped to the organization on nested users controller' do
      ability = described_class.new(
        user: super_admin,
        params: { organization_id: organization.id },
        controller_name: 'Api::V1::Organizations::Users'
      )

      expect(ability).to be_able_to(:manage, org_user)
      expect(ability).not_to be_able_to(:manage, create(:user, organization: create(:organization)))
    end
  end
end
