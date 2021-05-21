require 'swagger_helper'

RSpec.describe Api::V1::Organizations::ThemesController, type: :request do
  path '/api/v1/organizations/{organization_id}/themes' do
    get 'Show organization theme' do
      tags 'Organization Theme'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :organization_id, in: :path, type: :string
      response '200', 'Ok' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
  end
  path '/api/v1/organizations/{organization_id}/themes/{theme_id}' do
    get 'Show organization theme' do
      tags 'Organization Theme'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :organization_id, in: :path, type: :string
      parameter name: :theme_id, in: :path, type: :string
      response '200', 'Ok' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
    put 'Update organization theme' do
      tags 'Organization Theme'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :organization_id, in: :path, type: :string
      parameter name: :theme_id, in: :path, type: :string
      response '200', 'Ok' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '422', 'Invalid request' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
  end
end
