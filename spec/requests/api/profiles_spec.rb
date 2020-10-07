require 'rails_helper'

RSpec.describe Api::ProfilesController, type: :request do

  let!(:user) { create(:user) }

  describe '#GET /api/profiles/me' do
    it 'should retrieves current user' do
      get api_profiles_me_path, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#PUT /api/profiles/:id' do
    it 'should update user' do
      user.name = "new name"
      put api_profile_path(user.id), params: user.to_json, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      user.name = ""
      put api_profile_path(user.id), params: user.to_json, headers: auth_header(user)
      expect(response).to have_http_status(422)
    end
  end
end
