# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController, type: :request do
  describe '#POST create new account' do
    it 'when user is unauthenticated' do
      user = attributes_for(:user)
      post user_registration_path, params: user.to_json, headers: unauthenticated_header
      expect(response).to have_http_status(:ok)
    end

    it 'with invalid params' do
      post user_registration_path, params: {}, headers: unauthenticated_header
      expect(response).to have_http_status(:bad_request)
    end
  end
end
