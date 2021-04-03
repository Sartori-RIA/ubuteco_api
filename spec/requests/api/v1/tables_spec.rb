require 'swagger_helper'

RSpec.describe '/api/v1/tables', type: :request do
  path '/api/v1/tables' do
    get 'All Tables' do
      tags 'Tables'
      security [bearerAuth: []]
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Table' do
      tags 'Tables'
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
  path '/api/v1/tables/search' do
    get 'Search Table by name' do
      tags 'Tables'
      security [bearerAuth: []]
      consumes 'application/json'
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
  path '/api/v1/tables/{id}' do
    get 'Show Table' do
      tags 'Tables'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      response '401', 'Unauthorized' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
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
    put 'Update a Table' do
      tags 'Tables'
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
    delete 'Destroy a Table' do
      tags 'Tables'
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
end
