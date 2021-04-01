require 'swagger_helper'

RSpec.describe '/auth/password', type: :request do
  path '/api/v1/customers' do
    post 'Forgot password' do
      tags 'Auth'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
