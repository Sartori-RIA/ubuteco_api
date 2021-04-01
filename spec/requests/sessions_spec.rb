require 'swagger_helper'

RSpec.describe '/auth/sign_in', type: :request do
  path '/auth/sign_in' do
    post 'Sign In' do
      tags 'Auth'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end

  path '/auth/sign_out' do
    delete 'Sign out' do
      tags 'Auth'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
