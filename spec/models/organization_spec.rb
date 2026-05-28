# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe 'kitchen operational status' do
    it 'closes all open orders when kitchen is closed' do
      organization = create(:organization, operational_status: :open)
      open_order = create(:order, :open, organization: organization)
      closed_order = create(:order, :closed, organization: organization)

      organization.update!(operational_status: :closed)

      expect(open_order.reload).to be_closed
      expect(closed_order.reload).to be_closed
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:beers) }
    it { is_expected.to have_many(:makers) }
    it { is_expected.to have_many(:drinks) }
    it { is_expected.to have_many(:foods) }
    it { is_expected.to have_many(:orders) }
    it { is_expected.to have_many(:dishes) }
    it { is_expected.to have_many(:tables) }
    it { is_expected.to have_many(:users) }
  end
end
