# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::FoodsController, type: :request do
  before :each do
    @organization = create :organization
    @admin = @organization.user
    @admin.update(organization: @organization)
    @foods = create_list :food, 10, organization: @organization
  end

  describe '#GET /api/foods' do
    it 'should request all foods' do
      get api_foods_path, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/foods/:id' do
    it 'should request food by id' do
      get api_food_path(@foods.sample.id), headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/foods/search' do
    it 'should search foods' do
      get search_api_foods_path, params: { q: 'tralala' }, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/foods' do
    it 'should create a food' do
      attributes = attributes_for(:food).except(:user)
      post api_foods_path, params: attributes.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_foods_path, headers: auth_header(@admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/foods/:id' do
    let!(:food) { @foods.sample }
    it 'should update a food' do
      food.name = 'editado'
      put api_food_path(food.id), params: food.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      food.name = ''
      put api_food_path(food.id), params: food.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/foods/:id' do
    it 'should delete food' do
      delete api_food_path(@foods.sample.id), headers: auth_header(@admin)
      expect(response).to have_http_status(204)
    end
  end
end
