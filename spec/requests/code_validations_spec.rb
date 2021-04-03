require 'swagger_helper'

RSpec.describe CodeValidationsController, type: :request do
  path '/auth/code' do
    post 'Code received to reset your password' do
      tags 'Auth'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        run_test!
      end
      response '404', 'Not Found' do
        run_test!
      end
      response '422', 'Invalid request' do
        run_test!
      end
    end
  end
end
