# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::OrganizationsController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }

  describe '#GET /api/organizations' do
    it 'requests all organizations' do
      get api_v1_organizations_path, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/organizations/:id' do
    it 'requests organization by id' do
      get api_v1_organization_path(organization.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/organizations/check/phone' do
    it 'returns :ok status to phone in use' do
      get check_phone_api_v1_organizations_path, params: { q: organization.phone }, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end

    it 'returns :no_content status to phone available' do
      get check_phone_api_v1_organizations_path, params: { q: Faker::PhoneNumber.unique.phone_number },
                                                 headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe '#PUT /api/organizations/:id' do
    it 'updates a organization' do
      organization.name = 'editado'
      put api_v1_organization_path(organization.id), params: organization.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end

    it 'updates locale settings for admin' do
      patch api_v1_organization_path(organization.id),
            params: {
              locale: 'en',
              default_currency: 'USD',
              timezone: 'America/New_York'
            }.to_json,
            headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      organization.reload
      expect(organization.locale).to eq('en')
      expect(organization.default_currency).to eq('USD')
      expect(organization.timezone).to eq('America/New_York')
    end

    it 'does not allow waiter to change locale settings' do
      waiter = create(:user, :waiter, organization: organization)

      patch api_v1_organization_path(organization.id),
            params: { locale: 'en', default_currency: 'USD' }.to_json,
            headers: auth_header(waiter)

      expect(response).to have_http_status(:ok)
      organization.reload
      expect(organization.locale).to eq('pt-BR')
      expect(organization.default_currency).to eq('BRL')
    end

    it 'returns validation errors using organization locale' do
      organization.update!(locale: 'en')
      admin.reload

      patch api_v1_organization_path(organization.id),
            params: { name: '' }.to_json,
            headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.join(' ')).to match(/blank/i)
    end

    it 'throws error with invalid params' do
      organization.name = ''
      put api_v1_organization_path(organization.id), params: organization.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe '#DELETE /api/organizations/:id' do
    it 'deletes organization' do
      delete api_v1_organization_path(organization.id), headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
