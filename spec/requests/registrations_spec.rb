require 'swagger_helper'

RSpec.describe '/auth/sign_up', type: :request do
  path '/auth/sign_up' do
    post 'Create new account' do
      tags "Auth"
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
