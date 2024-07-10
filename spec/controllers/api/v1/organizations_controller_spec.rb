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

    it 'throws error with invalid params' do
      organization.name = ''
      put api_v1_organization_path(organization.id), params: organization.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/organizations/:id' do
    it 'deletes organization' do
      delete api_v1_organization_path(organization.id), headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
