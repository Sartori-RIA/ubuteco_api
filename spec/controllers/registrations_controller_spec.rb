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
    it 'without params bad_request, raise ParameterMissing' do
      expect { post user_registration_path, params: {}.to_json, headers: unauthenticated_header }.to raise_error ActionController::ParameterMissing, 'param is missing or the value is empty: user'
    end
    it 'without params bad_request' do
      post user_registration_path, params: { user: {name: "asd"} }.to_json, headers: unauthenticated_header
      expect(response).to have_http_status(:bad_request)
    end
    it 'with email already taken' do
      email = 'teste@teste.com'
      create(:user, email: email)
      attributes = { user: { email: email } }
      post user_registration_path, params: attributes.to_json, headers: unauthenticated_header
      expect(response).to have_http_status(:bad_request)
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
    it 'without params , raise ParameterMissing' do
      params = { user: attributes_for(:user), organization_attributes: {} }
      expect{ post user_registration_path, params: params.to_json, headers: unauthenticated_header }.to raise_error ActionController::ParameterMissing, 'param is missing or the value is empty: organization_attributes'
    end
    it 'without params bad_request' do
      post user_registration_path, params: { user: { name: "asd" } }.to_json, headers: unauthenticated_header
      expect(response).to have_http_status(:bad_request)
    end
    it 'with cnpj already taken' do
      cnpj = CNPJ.generate
      create(:organization, cnpj: cnpj)
      data = {
        user: attributes_for(:user),
        organization_attributes: attributes_for(:organization).merge(cnpj: cnpj),
      }
      post user_registration_path, params: data.to_json, headers: unauthenticated_header
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
