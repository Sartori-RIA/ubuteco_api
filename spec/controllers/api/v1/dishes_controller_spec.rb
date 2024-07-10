# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DishesController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:dishes) { create_list(:dish, 10, organization: organization) }

  describe '#GET /api/dishes' do
    it 'requests all dishes' do
      get api_v1_dishes_path, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/dishes/:id' do
    it 'requests dish by id' do
      get api_v1_dish_path(dishes.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#POST /api/dishes' do
    it 'creates a dish' do
      attributes = attributes_for(:dish).merge(organization_id: organization.id)
      post api_v1_dishes_path, params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:created)
    end

    it 'throws error with invalid params' do
      post api_v1_dishes_path, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#PUT /api/dishes/:id' do
    let!(:dish) { dishes.sample }

    it 'updates a dish' do
      put api_v1_dish_path(dish.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end

    it 'throws error with invalid params' do
      dish.name = ''
      put api_v1_dish_path(dish.id), params: dish.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/dishes/:id' do
    it 'deletes dish' do
      delete api_v1_dish_path(dishes.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
