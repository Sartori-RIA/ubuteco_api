require 'swagger_helper'

RSpec.describe '/api/v1/orders/{order_id}/items', type: :request do
  path '/api/v1/orders/{order_id}/items' do
    get 'All Items from order' do
      tags 'Order Items'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Add new item to order' do
      tags 'Order Items'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/orders/{order_id}/items/{item_id}' do
    put 'Update item in order' do
      tags 'Order Items'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Remove item in order' do
      tags 'Order Items'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
