require 'swagger_helper'

RSpec.describe PasswordsController, type: :request do
  before :all do
    @user = create(:user)
  end
  path '/auth/password' do
    put 'Forgot password' do
      tags 'Auth'
      consumes 'application/json'
      parameter name: :params, in: :body, type: :object, schema: {
        properties: {
          email: :string
        },
        required: ['email']
      }
      response '200', 'Ok' do
        let(:params) { { email: @user.email } }
        run_test!
      end
    end
  end
end
