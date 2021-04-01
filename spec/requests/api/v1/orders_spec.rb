require 'swagger_helper'

RSpec.describe '/api/v1/orders', type: :request do
  path '/api/v1/orders' do
    get 'All Orders' do
      tags 'Orders'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Order' do
      tags 'Orders'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/orders/search' do
    get 'Search Order by created_at, total_cents, total_with_discount_cents, table name, customer name' do
      tags 'Orders'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/orders/{id}' do
    get 'Show Order' do
      tags 'Orders'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Order' do
      tags 'Orders'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Order' do
      tags 'Orders'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
