# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Abilities::CustomerAbility, type: :ability do
  describe 'product scope' do
    let(:organization) { create(:organization) }
    let(:customer) { create(:user, :customer) }
    let(:beer) { build(:beer, organization: organization) }
    let(:other_beer) { build(:beer, organization: create(:organization)) }

    subject do
      described_class.new(
        user: customer,
        params: { organization_id: organization.id },
        controller_name: 'Api::V1::Beers'
      )
    end

    it { is_expected.to be_able_to(:read, beer) }
    it { is_expected.not_to be_able_to(:read, other_beer) }
  end
end
