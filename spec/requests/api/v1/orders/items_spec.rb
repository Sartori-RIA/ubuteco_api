require 'swagger_helper'

RSpec.describe Api::V1::Orders::ItemsController, type: :request do
  path '/api/v1/orders/{order_id}/items' do
    get 'All Items from order' do
      tags 'Order Items'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :order_id, in: :path, type: :string
      response '200', 'Ok' do
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
    post 'Add new item to order' do
      tags 'Order Items'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :order_id, in: :path, type: :string
      parameter in: :body, type: :object,
                schema: {
                  properties: {
                    item_id: { type: :integer },
                    item_type: { type: :string, example: %w[Beer Dish Drink Wine] },
                    quantity: { type: :integer },
                  },
                  required: %w[item_id item_type quantity]
                }
      response '201', 'Created' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        schema type: :object,
               properties: {
                 organization_id: { type: :integer },
                 table_id: { type: :integer },
                 status: { type: :integer },
                 user_id: { type: :integer },
                 discount: { type: :integer },
                 total: { type: :integer },
                 total_with_discount: { type: :integer },
               },
               required: %w[organization_id status]
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
  end
  path '/api/v1/orders/{order_id}/items/{item_id}' do
    put 'Update item in order' do
      tags 'Order Items'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :order_id, in: :path, type: :string
      parameter name: :item_id, in: :path, type: :string
      response '200', 'Ok' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        schema type: :object,
               properties: {
                 organization_id: { type: :integer },
                 table_id: { type: :integer },
                 status: { type: :integer },
                 user_id: { type: :integer },
                 discount: { type: :integer },
                 total: { type: :integer },
                 total_with_discount: { type: :integer },
               },
               required: %w[organization_id status]
        run_test!
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
    delete 'Remove item in order' do
      tags 'Order Items'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :order_id, in: :path, type: :string
      parameter name: :item_id, in: :path, type: :string
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
end
