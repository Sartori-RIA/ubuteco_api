# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe CodeValidationsController, type: :request do
  before :all do
    @token = '123456'
    @user = create(:user, reset_password_token: @token)
  end

  path '/auth/code' do
    post 'Code received to reset your password' do
      tags 'Auth'
      consumes 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          code: :string
        },
        required: ['code']
      }
      response '200', 'Ok' do
        let(:params) { { code: @token } }
        run_test!
      end
    end
  end
end
