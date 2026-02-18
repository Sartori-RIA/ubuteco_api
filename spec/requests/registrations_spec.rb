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
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: { '$ref' => '#/components/schemas/new_user' },
          organization_attributes: { '$ref' => '#/components/schemas/new_organization' }
        },
        required: ['user']
      }
      response '200', 'Account Created' do
        let(:params) { { user: attributes_for(:user), organization_attributes: attributes_for(:organization) } }
        run_test!
      end
      response '422', 'Unprocessable entity' do
        let(:params) { { user: { tralala: 'asd' } } }
        run_test!
      end
    end
  end
end
