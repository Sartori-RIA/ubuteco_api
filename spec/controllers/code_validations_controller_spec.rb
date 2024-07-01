# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CodeValidationsController, type: :request do
  let!(:user) { create(:user, :admin) }

  describe '#POST /auth/code_validations' do
    it 'returns user token when send code received in email' do
      token = SecureRandom.uuid
      user.reset_password_token = token
      user.save

      attributes = {
        code: token
      }
      post auth_code_path,
           params: attributes.to_json,
           headers: unauthenticated_header
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('token')
    end

    it 'throws error 404 when code not exists' do
      attributes = {
        code: 'bacon'
      }
      post auth_code_path,
           params: attributes.to_json,
           headers: unauthenticated_header
      expect(response).to have_http_status(:not_found)
    end
  end
end
