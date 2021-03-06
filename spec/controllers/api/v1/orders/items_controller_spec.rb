# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Orders::ItemsController, type: :request do
  before :all do
    @organization = create(:organization)
    @waiter = create(:user, :waiter, organization: @organization)
    @orders = create_list(:order, 10, :with_items, :open, organization: @organization)
    @maker = create(:maker, organization: @organization)
    @dish = create(:dish, organization: @organization)
    @wine = create(:wine, organization: @organization, maker: @maker)
    @beer = create(:beer, organization: @organization, maker: @maker)
    @drink = create(:drink, organization: @organization, maker: @maker)
  end

  describe '#GET /api/orders/:order_id/items' do
    it 'requests all order items' do
      get api_v1_order_items_path(order_id: @orders.sample.id), headers: auth_header(@waiter)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#POST /api/orders/:order_id/items' do
    let!(:order) { @orders.sample }

    it 'adds drink to order' do
      attributes = attributes_for(:order_item).merge(
        item_id: @drink.id,
        item_type: 'Drink',
        quantity: 10
      )
      post api_v1_order_items_path(order_id: order.id), params: attributes.to_json, headers: auth_header(@waiter)
      expect(response).to have_http_status(:created)
    end

    it 'adds beer to order' do
      attributes = attributes_for(:order_item).merge(
        item_type: 'Beer',
        item_id: @beer.id,
        quantity: 10
      )
      post api_v1_order_items_path(order_id: order.id), params: attributes.to_json, headers: auth_header(@waiter)
      expect(response).to have_http_status(:created)
    end

    it 'adds wines to order' do
      attributes = attributes_for(:order_item).merge(
        item_type: 'Wine',
        item_id: @wine.id,
        quantity: 10
      )
      post api_v1_order_items_path(order_id: order.id), params: attributes.to_json, headers: auth_header(@waiter)
      expect(response).to have_http_status(:created)
    end

    it 'adds wines to order' do
      attributes = attributes_for(:order_item).merge(
        item_id: @dish.id,
        item_type: 'Dish',
        quantity: 10
      )
      post api_v1_order_items_path(order_id: order.id), params: attributes.to_json, headers: auth_header(@waiter)
      expect(response).to have_http_status(:created)
    end

    it 'throws error with invalid params' do
      post api_v1_order_items_path(order_id: order.id), headers: auth_header(@waiter)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#PUT /api/orders/:order_id/items/:id' do
    let!(:order) { @orders.sample }
    let!(:item) { order.order_items.sample }

    it 'updates a order item' do
      item.quantity = 10
      put api_v1_order_item_path(order_id: order.id, id: item.id), params: item.to_json, headers: auth_header(@waiter)
      expect(response).to have_http_status(:ok)
    end

    it 'throws error with invalid params' do
      item.quantity = -99
      put api_v1_order_item_path(order_id: order.id, id: item.id), params: item.to_json, headers: auth_header(@waiter)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/orders/:order_id/items/:id' do
    let!(:order) { @orders.sample }
    let!(:item) { order.order_items.sample }

    it 'removes item from order' do
      delete api_v1_order_item_path(order_id: order.id, id: item.id), headers: auth_header(@waiter)
      expect(response).to have_http_status(:no_content)
    end
  end
end
