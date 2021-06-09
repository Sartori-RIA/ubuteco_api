require 'swagger_helper'

RSpec.describe Api::V1::Orders::ItemsController, type: :request do
  before :all do
    @organization = create(:organization)
    @user = create(:user_waiter, organization: @organization)
    @orders = create_list(:order, 10, :with_items, :open, organization: @organization)
    @order = @orders.sample
    @products = [
      create(:maker, organization: @organization),
      create(:dish, organization: @organization),
      create(:wine, organization: @organization),
      create(:beer, organization: @organization),
      create(:drink, organization: @organization)
    ]
  end

  path '/api/v1/orders/{order_id}/items' do
    get 'All Items from order' do
      tags 'Order Items'
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :order_id, in: :path, type: :string
      response '200', 'Ok' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:order_id) { @order.id }
        schema '$ref' => '#/components/schemas/order_items'
        run_test!
      end
    end
    post 'Add new item to order' do
      tags 'Order Items'
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :order_id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/new_order_item' }
      response '201', 'Created' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:order_id) { @order.id }
        let(:params) { attributes_for(:order_item).merge(item: @products.sample) }
        schema '$ref' => '#/components/schemas/order_item'
        run_test!
      end
      response '422', 'Invalid request' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:order_id) { @order.id }
        let(:params) { {} }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
  end
  path '/api/v1/orders/{order_id}/items/{item_id}' do
    put 'Update item in order' do
      tags 'Order Items'
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :order_id, in: :path, type: :string
      parameter name: :item_id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/order_item' }
      response '200', 'Ok' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:order_id) { @order.id }
        let(:params) { attributes_for(:order_item) }
        let(:item_id) { @order.order_items.sample.id }
        schema '$ref' => '#/components/schemas/order_item'
        run_test!
      end
      response '422', 'Ok' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:order_id) { @order.id }
        let(:item_id) { @order.order_items.sample.id }
        let(:params) { { quantity: -1 } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Remove item in order' do
      tags 'Order Items'
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :order_id, in: :path, type: :string
      parameter name: :item_id, in: :path, type: :string
      response '204', 'No Content' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:order_id) { @order.id }
        let(:item_id) { @order.order_items.sample.id }
        run_test!
      end
    end
  end
end
