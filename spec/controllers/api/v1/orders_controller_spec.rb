# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :request do
  before :all do
    @organization = create(:organization)
    @waiter = create(:user, :waiter, organization: @organization)
    @customer = create(:user, :customer)
    @orders = create_list(:order, 10, :with_items, organization: @organization, user: @customer)
  end

  describe '#GET /api/orders' do
    it 'requests all orders' do
      get api_v1_orders_path, headers: auth_header(@waiter)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/orders/:id' do
    it 'requests order by id' do
      get api_v1_order_path(@orders.sample.id), headers: auth_header(@waiter)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#POST /api/orders' do
    it 'creates a order' do
      attributes = attributes_for(:order).merge(organization_id: @organization.id)
      post api_v1_orders_path, params: attributes.to_json, headers: auth_header(@waiter)
      expect(response).to have_http_status(:created)
    end

    it 'throws error with invalid params' do
      attributes = attributes_for(:order)
      post api_v1_orders_path, params: attributes.to_json, headers: auth_header(@waiter)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#PUT /api/orders/:id' do
    let!(:order) { @orders.sample }

    it 'updates a table' do
      put api_v1_order_path(order.id), params: order.to_json, headers: auth_header(@waiter)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#DELETE /api/orders/:id' do
    it 'deletes order' do
      delete api_v1_order_path(@orders.sample.id), headers: auth_header(@waiter)
      expect(response).to have_http_status(:no_content)
    end
  end
end
