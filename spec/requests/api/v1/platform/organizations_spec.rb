# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Platform::OrganizationsController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:super_admin) { create(:user, :super_admin, organization: nil) }
  let!(:admin) { organization.user }

  describe 'GET /api/v1/platform/organizations' do
    it 'allows super admin to list organizations' do
      get api_v1_platform_organizations_path, headers: auth_header(super_admin)

      expect(response).to have_http_status(:ok)
    end

    it 'forbids org admin' do
      get api_v1_platform_organizations_path, headers: auth_header(admin)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /api/v1/platform/organizations/:id' do
    it 'allows super admin to show any organization' do
      get api_v1_platform_organization_path(organization), headers: auth_header(super_admin)

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /api/v1/platform/organizations/:organization_id/users' do
    it 'allows super admin to list users for an organization' do
      get api_v1_platform_organization_users_path(organization_id: organization.id),
          headers: auth_header(super_admin)

      expect(response).to have_http_status(:ok)
    end
  end
end
