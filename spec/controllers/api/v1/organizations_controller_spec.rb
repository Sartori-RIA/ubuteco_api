require 'rails_helper'

RSpec.describe Api::OrganizationsController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }

  describe '#GET /api/organizations' do
    it 'should request all organizations' do
      get api_v1_organizations_path, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/organizations/:id' do
    it 'should request organization by id' do
      get api_v1_organization_path(organization.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/organizations/search' do
    it 'should search organizations' do
      get search_api_v1_organizations_path, params: { q: 'tralala' }, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/organizations/check/cnpj' do
    it 'should return :ok status to cnpj in use' do
      get check_cnpj_api_v1_organizations_path, params: { q: organization.cnpj }, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
    it 'should return :no_content status to cnpj available' do
      get check_cnpj_api_v1_organizations_path, params: { q: Faker::Company.unique.brazilian_company_number }, headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end
  describe '#GET /api/organizations/check/phone' do
    it 'should return :ok status to phone in use' do
      get check_phone_api_v1_organizations_path, params: { q: organization.phone }, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
    it 'should return :no_content status to phone available' do
      get check_phone_api_v1_organizations_path, params: { q: Faker::PhoneNumber.unique.phone_number }, headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe '#PUT /api/organizations/:id' do
    it 'should update a organization' do
      organization.name = 'editado'
      put api_v1_organization_path(organization.id), params: organization.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
    it 'should throw error with invalid params' do
      organization.name = ''
      put api_v1_organization_path(organization.id), params: organization.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/organizations/:id' do
    it 'should delete organization' do
      delete api_v1_organization_path(organization.id), headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
