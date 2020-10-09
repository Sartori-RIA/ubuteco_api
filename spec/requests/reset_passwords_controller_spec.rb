require 'rails_helper'

RSpec.describe ResetPasswordsController, type: :request do
  let!(:user) { create(:user) }

  describe '#PUT /auth/reset_passwords' do
    it 'should update password when user forget then' do
      params = {
          password: '123456789'
      }
      put auth_reset_passwords_path,
          params: params.to_json,
          headers: auth_header(user)
      expect(response).to have_http_status(:ok)
      end
  end
end
