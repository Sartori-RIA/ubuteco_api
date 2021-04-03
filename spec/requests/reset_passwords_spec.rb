require 'swagger_helper'

RSpec.describe '/auth/reset_passwords', type: :request do
  path '/auth/reset_passwords' do
    post 'Change your password, when forgot' do
      tags 'Auth'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        run_test!
      end
      response '422', 'Invalid request' do
        run_test!
      end
    end
  end
end
