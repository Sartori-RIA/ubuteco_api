require 'rails_helper'

RSpec.describe PasswordsController, type: :request do
  let!(:user) { create(:user) }

  describe '#PUT /auth/passwords' do
    it 'should email code to reset password' do
      params = {
          email: user.email
      }
      post user_password_path,
           params: params.to_json,
           headers: unauthenticated_header
      expect(response).to have_http_status(:ok)
    end

    it 'should throw error when user not found' do
      params = {
          email: 'bacon@email.com'
      }
      post user_password_path,
           params: params.to_json,
           headers: unauthenticated_header
      expect(response).to have_http_status(:not_found)
    end
  end
end
