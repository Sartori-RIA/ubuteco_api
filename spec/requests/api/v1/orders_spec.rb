# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::OrdersController, type: :request do
  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @orders = create_list(:order, 10, organization: @organization)
  end

  path '/api/v1/orders' do
    get 'All Orders' do
      tags 'Orders'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/orders'
        run_test!
      end
    end
    post 'Create a Order' do
      tags 'Orders'
      security [Bearer: {}]
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/new_order' }
      response 201, 'Created' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:order).merge(organization_id: @organization.id) }
        schema '$ref' => '#/components/schemas/order'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { { organization_id: -9 } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
  end
  path '/api/v1/orders/{id}' do
    get 'Show Order' do
      tags 'Orders'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @orders.sample.id }
        run_test!
      end
    end
    put 'Update a Order' do
      tags 'Orders'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/edit_order' }
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @orders.sample.id }
        let(:params) { attributes_for(:order) }
        schema '$ref' => '#/components/schemas/order'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @orders.sample.id }
        let(:params) { { total: -9 } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Destroy a Order' do
      tags 'Orders'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 204, 'No Content' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @orders.sample.id }
        run_test!
      end
    end
  end
end
