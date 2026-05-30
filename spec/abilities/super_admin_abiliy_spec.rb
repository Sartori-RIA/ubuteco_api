# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Abilities::SuperAdminAbility, type: :ability do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }
  let(:super_admin) { create(:user, :super_admin) }
  let(:beer) { build(:beer, organization: organization) }
  let(:order) { build(:order, organization: organization) }
  let(:order_item) { build(:order_item, order: order) }

  subject do
    described_class.new(user: super_admin, params: {}, controller_name: 'Api::V1::Beers')
  end

  describe 'platform governance' do
    subject do
      described_class.new(
        user: super_admin,
        params: {},
        controller_name: 'Api::V1::Platform::Organizations'
      )
    end

    it { is_expected.to be_able_to(:manage, Organization.new) }
    it { is_expected.to be_able_to(:manage, Role.new) }
    it { is_expected.to be_able_to(:manage, BeerStyle.new) }
    it { is_expected.to be_able_to(:manage, WineStyle.new) }
  end

  describe 'catalog read on org routes' do
    it { is_expected.to be_able_to(:read, beer) }
    it { is_expected.not_to be_able_to(:create, beer) }
    it { is_expected.not_to be_able_to(:update, beer) }
    it { is_expected.not_to be_able_to(:destroy, beer) }
  end

  describe 'operational data on org routes' do
    it { is_expected.not_to be_able_to(:read, order) }
    it { is_expected.not_to be_able_to(:read, order_item) }

    it 'does not read users outside self on org routes' do
      org_user = build(:user, organization: organization)
      expect(subject).not_to be_able_to(:read, org_user)
    end
  end

  describe 'platform routes' do
    subject do
      described_class.new(
        user: super_admin,
        params: { organization_id: organization.id },
        controller_name: 'Api::V1::Platform::Organizations'
      )
    end

    it { is_expected.to be_able_to(:manage, organization) }
  end

  describe 'organization users (platform context only)' do
    it 'does not manage users on org-scoped users controller' do
      org_user = build(:user, organization: organization)
      ability = described_class.new(
        user: super_admin,
        params: {},
        controller_name: 'Api::V1::Users'
      )

      expect(ability).not_to be_able_to(:manage, org_user)
    end

    it 'manages users only on platform nested organization route' do
      org_user = build(:user, organization: organization)
      other_user = build(:user, organization: other_organization)
      ability = described_class.new(
        user: super_admin,
        params: { organization_id: organization.id },
        controller_name: 'Api::V1::Platform::Organizations::Users'
      )

      expect(ability).to be_able_to(:manage, org_user)
      expect(ability).not_to be_able_to(:manage, other_user)
    end
  end
end
