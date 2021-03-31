# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DishesController, type: :request do

  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:dishes) { create_list(:dish, 10, organization: organization) }

  describe '#GET /api/dishes' do
    it 'should request all dishes' do
      get api_v1_dishes_path, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/dishes/:id' do
    it 'should request dish by id' do
      get api_v1_dish_path(dishes.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/dishes/search' do
    it 'should search drishes' do
      get search_api_v1_dishes_path, params: { q: 'tralala' }, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/dishes' do
    it 'should create a dish' do
      attributes = attributes_for(:dish).merge(organization_id: organization.id)
      post api_v1_dishes_path, params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_v1_dishes_path, headers: auth_header(admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/dishes/:id' do
    let!(:dish) { dishes.sample }
    it 'should update a dish' do
      put api_v1_dish_path(dish.id), headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      dish.name = ''
      put api_v1_dish_path(dish.id), params: dish.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/dishes/:id' do
    it 'should delete dish' do
      delete api_v1_dish_path(dishes.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(204)
    end
  end
end
