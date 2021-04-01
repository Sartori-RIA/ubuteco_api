require 'swagger_helper'

RSpec.describe '/auth/code', type: :request do
  path '/auth/code' do
    post 'Code received to reset your password' do
      tags 'Auth'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
