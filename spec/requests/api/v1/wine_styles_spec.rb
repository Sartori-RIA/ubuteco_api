require 'swagger_helper'

RSpec.describe 'api/v1/wine_styles', type: :request do
  path '/api/v1/wine_styles' do
    get 'All Wine Styles' do
      tags 'Wine Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Wine Style' do
      tags 'Wine Styles'
      security [bearerAuth: []]
      consumes 'application/json'
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
      response '401', 'Unauthorized' do
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
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
