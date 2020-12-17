require 'rails_helper'

RSpec.describe Api::Organizations::ThemesController, type: :request do
  let!(:user) { create(:user_admin) }
  let!(:theme) { create(:theme, organization: user.organization) }

  describe '#GET /api/users/:id/themes' do
    it 'should request user theme' do
      get api_user_themes_path(user_id: theme.user_id), headers: auth_header(theme.user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/users/:id/themes/:id' do
    it 'should request user theme' do
      get api_user_theme_path(user_id: theme.user_id, id: theme.id), headers: auth_header(theme.user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#PUT /api/users/:id/themes/:id' do
    it 'should update user theme' do
      put api_user_theme_path(user_id: theme.user_id, id: theme.id), params: theme.to_json, headers: auth_header(theme.user)
      expect(response).to have_http_status(200)
    end
  end
end
