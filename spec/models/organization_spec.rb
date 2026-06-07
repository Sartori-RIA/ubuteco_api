# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe 'locale settings' do
    subject(:organization) { build(:organization) }

    it 'defaults locale, currency, and timezone' do
      org = create(:organization)
      expect(org.locale).to eq('pt-BR')
      expect(org.default_currency).to eq('BRL')
      expect(org.timezone).to eq('America/Sao_Paulo')
    end

    it 'accepts supported locale, currency, and timezone' do
      organization.locale = 'en'
      organization.default_currency = 'USD'
      organization.timezone = 'America/New_York'
      expect(organization).to be_valid
    end

    it 'accepts Canadian locale and currency' do
      organization.locale = 'en-CA'
      organization.default_currency = 'CAD'
      organization.timezone = 'America/Toronto'
      expect(organization).to be_valid

      organization.locale = 'fr-CA'
      organization.timezone = 'America/Montreal'
      expect(organization).to be_valid
    end

    it 'accepts French locale' do
      organization.locale = 'fr'
      organization.default_currency = 'EUR'
      organization.timezone = 'Europe/Paris'
      expect(organization).to be_valid
    end

    it 'rejects unknown locale' do
      organization.locale = 'zzz'
      expect(organization).not_to be_valid
      expect(organization.errors[:locale]).to be_present
    end

    it 'rejects unknown currency' do
      organization.default_currency = 'ZZZ'
      expect(organization).not_to be_valid
      expect(organization.errors[:default_currency]).to be_present
    end

    it 'rejects unknown timezone' do
      organization.timezone = 'Not/A_Timezone'
      expect(organization).not_to be_valid
      expect(organization.errors[:timezone]).to be_present
    end
  end

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
