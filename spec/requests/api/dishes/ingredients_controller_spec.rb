# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Dishes::IngredientsController, type: :request do

  let!(:organization) { create :organization }
  let!(:admin) do
    organization.user.update(organization: organization)
    organization.user
  end
  let!(:foods) { create_list :food, 10, organization: organization }
  let!(:dishes) { create_list :dish, 10, organization: organization }
  let!(:dish_ingredients) { create_list :dish_ingredient, 10, food: foods.sample, dish: dishes.sample }

  describe '#GET /api/dishes/:dish_id/ingredients' do
    let!(:dish) { dishes.sample }
    it 'should request all dish ingredients' do
      get api_dish_ingredients_path(dish_id: dish.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#POST /api/dishes/:dish_id/ingredients' do
    let!(:dish) { dishes.sample }
    it 'should add ingredient to dish' do
      attributes = attributes_for(:dish_ingredient).merge(
        food_id: foods.sample.id
      )
      post api_dish_ingredients_path(dish_id: dish.id), params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:created)
    end
    it 'should throw error with invalid params' do
      post api_dish_ingredients_path(dish_id: dish.id), headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#PUT /api/dishes/:dish_id/ingredients/:id' do
    let!(:dish) { dishes.sample }
    let!(:ingredient) { dish.dish_ingredients.sample }
    it 'should update a dish ingredient' do
      ingredient.quantity = 10
      put api_dish_ingredient_path(dish_id: dish.id, id: ingredient.id), params: ingredient.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
    it 'should throw error with invalid params' do
      ingredient.quantity = nil
      put api_dish_ingredient_path(dish_id: dish.id, id: ingredient.id), params: ingredient.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/dishes/:dish_id/ingredients/:id' do
    let!(:dish) { dishes.sample }
    let!(:dish_ingredients) { create_list(:dish_ingredient, 10, food: foods.sample, dish: dish) }
    let!(:ingredient) { dish_ingredients.sample }
    it 'should remove ingredient from dish' do
      puts ingredient.to_json
      delete api_dish_ingredient_path(dish_id: ingredient.dish_id, id: ingredient.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end
end
