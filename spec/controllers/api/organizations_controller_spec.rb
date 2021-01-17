require 'rails_helper'

RSpec.describe Api::OrganizationsController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) do
    organization.user.update(organization: organization)
    organization.user
  end

  describe '#GET /api/organizations' do
    it 'should request all organizations' do
      get api_organizations_path, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/organizations/:id' do
    it 'should request organization by id' do
      get api_organization_path(organization.id), headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/organizations/search' do
    it 'should search organizations' do
      get search_api_organizations_path, params: { q: 'tralala' }, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#PUT /api/organizations/:id' do
    it 'should update a organization' do
      organization.name = 'editado'
      put api_organization_path(organization.id), params: organization.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      organization.name = ''
      put api_organization_path(organization.id), params: organization.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/organizations/:id' do
    it 'should delete organization' do
      delete api_organization_path(organization.id), headers: auth_header(admin)
      expect(response).to have_http_status(204)
    end
  end
end
