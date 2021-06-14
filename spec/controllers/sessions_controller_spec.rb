# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  let!(:user) { create(:user, :admin) }

  describe 'when params are correct' do
    it 'signs in with email' do
      params = {
        email: user.email,
        password: user.password
      }
      post user_session_path, params: params.to_json, headers: unauthenticated_header
      expect(response).to have_http_status(:ok)
      expect(response.headers['Authorization']).to be_present
    end
  end

  context 'when login params are incorrect' do
    it 'returns unauthorized status' do
      post user_session_path, params: {}, headers: unauthenticated_header
      expect(response.headers['Authorization']).to be_nil
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '#DELETE JWR' do
    it 'returns 200, no content' do
      delete destroy_user_session_path, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end
end
