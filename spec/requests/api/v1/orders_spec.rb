require 'swagger_helper'

RSpec.describe '/api/v1/orders', type: :request do
  path '/api/v1/orders' do
    get 'All Orders' do
      tags 'Orders'
      security [bearerAuth: []]
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Order' do
      tags 'Orders'
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
      response '422', 'Invalid request' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
  end
  path '/api/v1/orders/search' do
    get 'Search Order by created_at, total_cents, total_with_discount_cents, table name, customer name' do
      tags 'Orders'
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
  path '/api/v1/orders/{id}' do
    get 'Show Order' do
      tags 'Orders'
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
    put 'Update a Order' do
      tags 'Orders'
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
    delete 'Destroy a Order' do
      tags 'Orders'
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
