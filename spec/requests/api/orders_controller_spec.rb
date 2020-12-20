# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::OrdersController, type: :request do
  before :all do
    @organization = create :organization
    @admin = @organization.user
    @admin.update(organization: @organization)
    @customer = create :user_customer
    @orders = create_list :order, 10, organization: @organization
  end

  describe '#GET /api/orders' do
    it 'should request all orders' do
      get api_orders_path, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/orders/:id' do
    it 'should request order by id' do
      get api_order_path(@orders.sample.id), headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/orders/search' do
    it 'should search orders' do
      get search_api_orders_path, params: { q: 'tralala' }, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/orders' do
    it 'should create a order' do
      attributes = attributes_for(:order).except(:user)
      post api_orders_path, params: attributes.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(201)
    end
  end

  describe '#PUT /api/orders/:id' do
    let!(:order) { @orders.sample }
    it 'should update a table' do
      put api_order_path(order.id), params: order.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#DELETE /api/orders/:id' do
    it 'should delete order' do
      delete api_order_path(@orders.sample.id), headers: auth_header(@admin)
      expect(response).to have_http_status(204)
    end
  end
end
