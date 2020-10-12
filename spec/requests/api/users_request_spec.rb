require 'rails_helper'

RSpec.describe Api::UsersController, type: :request do
  let!(:user) { create(:user) }

  describe '#GET /api/users' do
    it 'should retrieves all user' do
      get api_users_path, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/users/:id' do
    it 'should retrieves current user' do
      get api_users_path(user.id), headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#PUT /api/users/:id' do
    it 'should update user' do
      user.name = 'new name'
      put api_user_path(user.id), params: user.to_json, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      user.name = ''
      put api_user_path(user.id), params: user.to_json, headers: auth_header(user)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/users/:id' do
    it 'should delete user' do
      delete api_user_path(user.id), headers: auth_header(user)
      expect(response).to have_http_status(204)
    end
  end
end
