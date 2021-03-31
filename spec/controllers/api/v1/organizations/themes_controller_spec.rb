require 'rails_helper'

RSpec.describe Api::V1::Organizations::ThemesController, type: :request do

  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:theme) { create(:theme, organization: organization) }

  describe '#GET /api/users/:id/themes' do
    it 'should request user theme' do
      get api_v1_organization_themes_path(
            organization_id: theme.organization_id
          ),
          headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/users/:id/themes/:id' do
    it 'should request user theme' do
      get api_v1_organization_theme_path(
            organization_id: theme.organization_id,
            id: theme.id
          ),
          headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#PUT /api/users/:id/themes/:id' do
    it 'should update user theme' do
      put api_v1_organization_theme_path(
            organization_id: theme.organization_id,
            id: theme.id
          ),
          params: theme.to_json,
          headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end
end
