require 'swagger_helper'

RSpec.describe Api::V1::Orders::ItemsController, type: :request do
  path '/api/v1/orders/{order_id}/items' do
    get 'All Items from order' do
      tags 'Order Items'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :order_id, in: :path, type: :string
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
    post 'Add new item to order' do
      tags 'Order Items'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :order_id, in: :path, type: :string
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
  path '/api/v1/orders/{order_id}/items/{item_id}' do
    put 'Update item in order' do
      tags 'Order Items'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :order_id, in: :path, type: :string
      parameter name: :item_id, in: :path, type: :string
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        run_test!
      end
      response '404', 'Not Found' do
        run_test!
      end
    end
    delete 'Remove item in order' do
      tags 'Order Items'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :order_id, in: :path, type: :string
      parameter name: :item_id, in: :path, type: :string
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        run_test!
      end
      response '404', 'Not Found' do
        run_test!
      end
    end
  end
end
