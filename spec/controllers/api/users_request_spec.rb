require 'rails_helper'

RSpec.describe Api::UsersController, type: :request do

  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:roles) { create_list(:role, 5) }

  describe '#GET /api/users' do
    it 'should retrieves all user' do
      get api_users_path, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/users/:id' do
    it 'should retrieves user by id' do
      get api_user_path(admin.id), headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/users/search' do
    it 'should search drinks' do
      get search_api_users_path, params: { q: 'tralala' }, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/users/check/email' do
    it 'should return :ok status to style in use' do
      get check_email_api_users_path, params: { q: admin.email }, headers: unauthenticated_header
      expect(response).to have_http_status(:ok)
    end
    it 'should return :no_content status to style available' do
      get check_email_api_users_path, params: { q: Faker::Internet.unique.email }, headers: unauthenticated_header
      expect(response).to have_http_status(:no_content)
    end
  end

  describe '#POST /api/users' do
    it 'should create user' do
      attributes = attributes_for(:user).merge(
        role_id: roles.sample.id,
        organization_id: organization.id
      )
      post api_users_path, params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_users_path, params: {}, headers: auth_header(admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/users/:id' do
    it 'should update user' do
      admin.name = 'new name'
      put api_user_path(admin.id), params: admin.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      admin.name = ''
      put api_user_path(admin.id), params: admin.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/users/:id' do
    it 'should delete user' do
      delete api_user_path(admin.id), headers: auth_header(admin)
      expect(response).to have_http_status(204)
    end
  end
end
