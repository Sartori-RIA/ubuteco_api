# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe RegistrationsController, type: :request do
  before :all do
    create(:admin)
    create(:customer)
  end

  path '/auth/sign_up' do
    post 'Create new account' do
      tags 'Auth'
      consumes 'application/json'
      response '201', 'Created' do
        run_test!
      end
      response '422', 'Invalid request' do
        run_test!
      end
    end
  end
end
