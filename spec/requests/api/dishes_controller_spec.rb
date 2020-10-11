# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DishesController, type: :request do
  let!(:user) { create(:user) }
  let!(:dishes) { create_list(:dish, 10, user: user) }

  describe '#GET /api/dishes' do
    it 'should request all dishes' do
      get api_dishes_path, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/dishes/:id' do
    it 'should request dish by id' do
      get api_dish_path(dishes.sample.id), headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/dishes/search' do
    it 'should search drishes' do
      get search_api_dishes_path, params: {q: 'tralala'}, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/dishes' do
    it 'should create a dish' do
      attributes = attributes_for(:dish).except(:user)
      post api_dishes_path, params: attributes.to_json, headers: auth_header(user)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_dishes_path, headers: auth_header(user)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/dishes/:id' do
    let!(:dish) {dishes.sample}
    it 'should update a dish' do
      put api_dish_path(dish.id), headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      dish.name = ''
      put api_dish_path(dish.id), params: dish.to_json, headers: auth_header(user)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/dishes/:id' do
    it 'should delete dish' do
      delete api_dish_path(dishes.sample.id), headers: auth_header(user)
      expect(response).to have_http_status(204)
    end
  end
end
