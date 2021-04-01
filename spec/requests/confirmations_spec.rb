require 'swagger_helper'

RSpec.describe '/auth/confirmations', type: :request do
  path '/auth/confirmations' do
    post 'Confirm your email' do
      tags 'Auth'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
