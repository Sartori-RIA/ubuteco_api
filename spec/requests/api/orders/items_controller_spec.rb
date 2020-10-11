# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Orders::ItemsController, type: :request do
  let!(:user) { create(:user) }
  let!(:dishes) { create_list(:dish, 10, user: user) }
  let!(:wines) { create_list(:wine, 10, user: user) }
  let!(:beers) { create_list(:beer, 10, user: user) }
  let!(:drinks) { create_list(:drink, 10, user: user) }
  let!(:orders) { create_list(:order_with_items, 10, user: user) }
  let!(:order) { orders.sample }
  let!(:item) { order.order_items.sample }

  describe '#GET /api/orders/:order_id/ingredients' do
    it 'should request all order items' do
      get api_order_items_path(order_id: order.id), headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/orders/:order_id/item' do
    it 'should add drink to order' do
      attributes = attributes_for(:order_item).merge(
        item_id: drinks.sample.id,
        item_type: 'Drink',
        order_id: order.id,
        quantity: 10
      )
      post api_order_items_path(order_id: order.id), params: attributes.to_json, headers: auth_header(user)
      expect(response).to have_http_status(201)
    end
    it 'should add beer to order' do
      attributes = attributes_for(:order_item).merge(
        item_type: 'Beer',
        item_id: beers.sample.id,
        order_id: order.id,
        quantity: 10
      )
      post api_order_items_path(order_id: order.id), params: attributes.to_json, headers: auth_header(user)
      expect(response).to have_http_status(201)
    end
    it 'should add wines to order' do
      attributes = attributes_for(:order_item).merge(
        item_type: 'Wine',
        item_id: wines.sample.id,
        order_id: order.id,
        quantity: 10
      )
      post api_order_items_path(order_id: order.id), params: attributes.to_json, headers: auth_header(user)
      expect(response).to have_http_status(201)
    end
    it 'should add wines to order' do
      attributes = attributes_for(:order_item).merge(
        item_id: dishes.sample.id,
        item_type: 'Dish',
        order_id: order.id,
        quantity: 10
      )
      post api_order_items_path(order_id: order.id), params: attributes.to_json, headers: auth_header(user)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_order_items_path(order_id: order.id), headers: auth_header(user)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/orders/:order_id/items/:id' do
    it 'should update a order item' do
      item.quantity = 10
      put api_order_item_path(order_id: order.id, id: item.id), params: item.to_json, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      item.quantity = nil
      put api_order_item_path(order_id: order.id, id: item.id), params: item.to_json, headers: auth_header(user)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/orders/:order_id/items/:id' do
    it 'should remove item from order' do
      delete api_order_item_path(order_id: order.id, id: item.id), headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end
end
