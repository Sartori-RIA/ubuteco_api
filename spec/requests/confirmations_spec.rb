require 'swagger_helper'

RSpec.describe ConfirmationsController, type: :request do
  path '/auth/confirmations' do
    post 'Confirm your email' do
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
