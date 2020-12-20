require 'rails_helper'

RSpec.describe Api::UsersController, type: :request do
  before :each do
    @organization = create :organization
    @admin = @organization.user
    @roles = create_list :role, 5
    @admin.update(organization: @organization)
  end

  describe '#GET /api/users' do
    it 'should retrieves all user' do
      get api_users_path, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/users/:id' do
    it 'should retrieves user by id' do
      get api_users_path(@admin.id), headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

 describe '#POST /api/users' do
    it 'should create user' do
      attributes = attributes_for(:user).merge(
        role_id: @roles.sample.id
      )
      post api_users_path, params: attributes.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(201)
    end
   it 'should throw error with invalid params' do
      post api_users_path, params: {}, headers: auth_header(@admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/users/:id' do
    it 'should update user' do
      @admin.name = 'new name'
      put api_user_path(@admin.id), params: @admin.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      @admin.name = ''
      put api_user_path(@admin.id), params: @admin.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/users/:id' do
    it 'should delete user' do
      delete api_user_path(@admin.id), headers: auth_header(@admin)
      expect(response).to have_http_status(204)
    end
  end
end
