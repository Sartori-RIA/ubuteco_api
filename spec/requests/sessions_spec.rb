require 'swagger_helper'

RSpec.describe SessionsController, type: :request do
  path '/auth/sign_in' do
    post 'Sign In' do
      tags 'Auth'
      consumes 'application/json'
      parameter in: :body, type: :object, schema: {
        properties: {
          email: { type: :string },
          password: { type: :string },
        },
        required: %w[email password]
      }
      response '200', 'OK' do
        run_test!
      end
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end

  path '/auth/sign_out' do
    delete 'Sign out' do
      tags 'Auth'
      consumes 'application/json'
      response '200', 'Unauthorized' do
        run_test!
      end
    end
  end
end
