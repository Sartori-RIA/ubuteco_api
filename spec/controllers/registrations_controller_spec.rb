# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController, type: :request do
  let!(:role_admin) { create(:admin) }
  let!(:role_customer) { create(:customer) }

  describe '#POST create new account' do
    it 'with valid params' do
      data = { user: attributes_for(:user) }
      post user_registration_path, params: data.to_json, headers: unauthenticated_header
      expect(response).to have_http_status(:ok)
    end

    it 'without params bad_request' do
      post user_registration_path, params: {}, headers: unauthenticated_header
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
  describe '#POST create new account with organization' do
    it 'with valid params' do
      data = {
        user: attributes_for(:user),
        organization_attributes: attributes_for(:organization)
      }
      post user_registration_path, params: data.to_json, headers: unauthenticated_header
      expect(response).to have_http_status(:ok)
    end

    it 'without params unprocessable_entity' do
      post user_registration_path, params: {}.to_json, headers: unauthenticated_header
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'without params bad_request' do
      post user_registration_path, params: {user: {}}.to_json, headers: unauthenticated_header
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
