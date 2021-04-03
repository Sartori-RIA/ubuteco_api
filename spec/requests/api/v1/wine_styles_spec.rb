require 'swagger_helper'

RSpec.describe Api::V1::WinesController, type: :request do
  path '/api/v1/wine_styles' do
    get 'All Wine Styles' do
      tags 'Wine Styles'
      consumes 'application/json'
      response '200', 'Ok' do
        run_test!
      end
    end
    post 'Create a Wine Style' do
      tags 'Wine Styles'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter in: :body, type: :object,
                schema: {
                  properties: {
                    name: { type: :string }
                  },
                  required: %w[name]
                }
      response '201', 'Created' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string }
               },
               required: %w[id name]
        run_test!
      end
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '422', 'Invalid request' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
  end
  path '/api/v1/wine_styles/{id}' do
    get 'Show Wine Style' do
      tags 'Wine Styles'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      response '200', 'Ok' do
        run_test!
      end
      response '404', 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
    put 'Update a Wine Style' do
      tags 'Wine Styles'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter in: :body, type: :object,
                schema: {
                  properties: {
                    name: { type: :string }
                  },
                  required: %w[name]
                }
      response '200', 'Ok' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string }
               },
               required: %w[name]
        run_test!
      end
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '404', 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '422', 'Invalid request' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
    delete 'Destroy a Wine Style' do
      tags 'Wine Styles'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      response '204', 'No Content' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '404', 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
  end
  path '/api/v1/wine_styles/check/style' do
    get 'Check available name' do
      tags 'Wine Styles'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :q, in: :query, type: :string
      response '200', 'Already Exists' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '204', 'Name available' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Unauthorized' do
        run_test!
      end
    end
  end
end
