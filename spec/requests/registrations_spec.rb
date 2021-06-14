require 'swagger_helper'

RSpec.describe RegistrationsController, type: :request do
  before :all do
    create(:role, :admin)
    create(:role, :customer)
  end
  path '/auth/sign_up' do
    post 'Create new account' do
      tags "Auth"
      consumes 'application/json'
      response '201', 'Created' do

      end
      response '422', 'Invalid request' do
        run_test!
      end
    end
  end
end
