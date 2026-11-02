# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe ResetPasswordsController, type: :request do
  before :all do
    @user = create(:organization).user
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
        let(:Authorization) { auth_header(@user)['Authorization'] }
        let(:params) { { reset_params: { password: 'brand-new-secret', current_password: 'factory-secret' } } }
        schema '$ref' => '#/components/schemas/user'
        run_test!
      end

      response '422', 'current password missing' do
        let(:Authorization) { auth_header(@user)['Authorization'] }
        let(:params) { { reset_params: { password: 'brand-new-secret' } } }
        run_test! do
          expect(response.parsed_body['errors'].first['code']).to eq('current_password_invalid')
        end
      end
    end
  end
end
