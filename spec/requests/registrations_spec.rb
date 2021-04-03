require 'swagger_helper'

RSpec.describe RegistrationsController, type: :request do
  path '/auth/sign_up' do
    post 'Create new account' do
      tags "Auth"
      consumes 'application/json'
      response '422', 'Invalid request' do
        run_test!
      end
    end
  end
end
