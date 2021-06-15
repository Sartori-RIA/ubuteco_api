# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConfirmationsController, type: :request do
  let!(:user) { create(:user,:admin) }

  describe '#GET should confirm user account creation' do
    it 'should confirm user account' do
      token = generate_code
      user.update(confirmed_at: nil, confirmation_token: token)
      get user_confirmation_path(confirmation_token: token),
          headers: unauthenticated_header
      expect(response).to have_http_status(:ok)
    end

    it 'should throw error when user already confirm account' do
      token = generate_code
      user.update(confirmed_at: Time.zone.now, confirmation_token: token)
      get user_confirmation_path(confirmation_token: token),
          headers: unauthenticated_header
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
