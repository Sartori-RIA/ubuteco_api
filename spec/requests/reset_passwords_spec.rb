require 'swagger_helper'

RSpec.describe ResetPasswordsController, type: :request do
  before :all do
    @user = create(:user, :admin)
  end
  path '/auth/reset_passwords' do
    put 'Change your password, when forgot' do
      tags 'Auth'
      consumes 'application/json'
      security [Bearer: {}]
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          reset_params: {
            type: :object,
            properties: {
              password: :string
            }
          }
        },
        required: ['reset_params']
      }
      response '200', 'Ok' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:params) { { reset_params: { password: '123123123' } } }
        schema '$ref' => '#/components/schemas/user'
        run_test!
      end
    end
  end
end
