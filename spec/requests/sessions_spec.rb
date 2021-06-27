# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe SessionsController, type: :request do
  let!(:user) { create(:user, password: '123123123') }

  path '/auth/sign_in' do
    post 'Sign In' do
      tags 'Auth'
      consumes 'application/json'
      parameter name: :params, in: :body, type: :object, schema: {
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[email password]
      }
      response '200', 'OK' do
        let(:params) { { email: user.email, password: '123123123' } }
        run_test!
      end
      response '401', 'Unauthorized' do
        let(:params) { { email: user.email, password: 'tralala' } }
        run_test!
      end
    end
  end

  path '/auth/sign_out' do
    delete 'Sign out' do
      tags 'Auth'
      security [Bearer: {}]
      consumes 'application/json'
      response '200', 'Unauthorized' do
        let(:Authorization) { auth_header(user)['Authorization'] }
        run_test!
      end
    end
  end
end
