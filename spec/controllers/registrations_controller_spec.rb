# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController, type: :request do
  let!(:role_admin) { create(:admin) }
  let!(:role_customer) { create(:customer) }

  describe '#POST create new account' do
    context 'with success' do
      it 'with valid params' do
        data = { user: attributes_for(:user) }
        post user_registration_path, params: data.to_json, headers: unauthenticated_header
        expect(response).to have_http_status(:ok)
      end
    end
    context 'with error' do
      it 'without params bad_request' do
        post user_registration_path, params: { user: { name: "asd" } }.to_json, headers: unauthenticated_header
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'with email already taken' do
        user = create(:user)
        attributes = { user: { email: user.email } }
        post user_registration_path, params: attributes.to_json, headers: unauthenticated_header
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'with valid params' do
        data = { user: attributes_for(:user).merge(password: '1') }
        post user_registration_path, params: data.to_json, headers: unauthenticated_header
        expect(response).to have_http_status(:unprocessable_entity)
      end
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
    it 'without params bad_request' do
      post user_registration_path, params: { user: { name: "asd" } }.to_json, headers: unauthenticated_header
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'with cnpj already taken' do
      org = create(:organization)
      data = {
        user: attributes_for(:user),
        organization_attributes: attributes_for(:organization).merge(cnpj: org.cnpj),
      }
      post user_registration_path, params: data.to_json, headers: unauthenticated_header
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
