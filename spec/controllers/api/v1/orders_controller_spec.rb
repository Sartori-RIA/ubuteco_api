# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :request do
  before :all do
    @organization = create(:organization)
    @waiter = create(:user_waiter, organization: @organization)
    @customer = create(:user_customer)
    @orders = create_list(:order, 10, :with_items, organization: @organization, user: @customer)
  end

  describe '#GET /api/orders' do
    it 'should request all orders' do
      get api_v1_orders_path, headers: auth_header(@waiter)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/orders/:id' do
    it 'should request order by id' do
      get api_v1_order_path(orders.sample.id), headers: auth_header(@waiter)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/orders/search' do
    it 'should search orders' do
      get search_api_v1_orders_path, params: { q: 'tralala' }, headers: auth_header(@waiter)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/orders' do
    it 'should create a order' do
      attributes = attributes_for(:order).merge(organization_id: @organization.id)
      post api_v1_orders_path, params: attributes.to_json, headers: auth_header(@waiter)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      attributes = attributes_for(:order)
      post api_v1_orders_path, params: attributes.to_json, headers: auth_header(@waiter)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/orders/:id' do
    let!(:order) { orders.sample }
    it 'should update a table' do
      put api_v1_order_path(order.id), params: order.to_json, headers: auth_header(@waiter)
      expect(response).to have_http_status(200)
    end
  end

  describe '#DELETE /api/orders/:id' do
    it 'should delete order' do
      delete api_v1_order_path(orders.sample.id), headers: auth_header(@waiter)
      expect(response).to have_http_status(204)
    end
  end
end
