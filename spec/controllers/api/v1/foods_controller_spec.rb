# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::FoodsController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:foods) { create_list(:food, 10, organization: organization) }

  describe '#GET /api/foods' do
    it 'requests all foods' do
      get api_v1_foods_path, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/foods/:id' do
    it 'requests food by id' do
      get api_v1_food_path(foods.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#POST /api/foods' do
    it 'creates a food' do
      attributes = attributes_for(:food).merge(organization_id: organization.id)
      post api_v1_foods_path, params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:created)
    end

    it 'throws error with invalid params' do
      post api_v1_foods_path, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#PUT /api/foods/:id' do
    let!(:food) { foods.sample }

    it 'updates a food' do
      food.name = 'editado'
      put api_v1_food_path(food.id), params: food.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end

    it 'throws error with invalid params' do
      food.name = ''
      put api_v1_food_path(food.id), params: food.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/foods/:id' do
    it 'deletes food' do
      delete api_v1_food_path(foods.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
