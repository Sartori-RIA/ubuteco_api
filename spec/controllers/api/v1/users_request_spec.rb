# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:roles) { create_list(:role, 5) }

  describe '#GET /api/users/:id' do
    it 'retrieveses user by id' do
      get api_v1_user_path(admin.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/users/check/email' do
    it 'returns :ok status to style in use' do
      get check_email_api_v1_users_path, params: { q: admin.email }, headers: unauthenticated_header
      expect(response).to have_http_status(:ok)
    end

    it 'returns :no_content status to style available' do
      get check_email_api_v1_users_path, params: { q: Faker::Internet.unique.email }, headers: unauthenticated_header
      expect(response).to have_http_status(:no_content)
    end
  end

  describe '#POST /api/users' do
    it 'creates user' do
      attributes = attributes_for(:user).merge(
        role_id: roles.sample.id,
        organization_id: organization.id
      )
      post api_v1_users_path, params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:created)
    end

    it 'throws error with invalid params' do
      post api_v1_users_path, params: {}, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#PUT /api/users/:id' do
    it 'updates user' do
      admin.name = 'new name'
      put api_v1_user_path(admin.id), params: admin.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end

    it 'throws error with invalid params' do
      admin.name = ''
      put api_v1_user_path(admin.id), params: admin.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/users/:id' do
    it 'deletes user' do
      delete api_v1_user_path(admin.id), headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
