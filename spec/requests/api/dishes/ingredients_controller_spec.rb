# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Dishes::IngredientsController, type: :request do
  let!(:user) { create(:user) }
  let!(:foods) { create_list(:food, 10, user: user) }
  let!(:dishes_with_ingredients) { create_list(:dish_with_ingredients, 10, user: user) }
  let!(:dish) { dishes_with_ingredients.sample }
  let!(:ingredient) { dish.dish_ingredients.sample }

  describe '#GET /api/dishes/:dish_id/ingredients' do
    it 'should request all dish ingredients' do
      get api_dish_ingredients_path(dish_id: dish.id), headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/dishes/:dish_id/ingredients' do
    let!(:dish) { dishes_with_ingredients.sample }
    it 'should add ingredient to dish' do
      attributes = attributes_for(:dish_ingredient).merge(
        food_id: foods.sample.id
      )
      post api_dish_ingredients_path(dish_id: dish.id), params: attributes.to_json, headers: auth_header(user)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_dish_ingredients_path(dish_id: dish.id), headers: auth_header(user)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/dishes/:dish_id/ingredients/:id' do
    it 'should update a dish ingredient' do
      ingredient.quantity = 10
      put api_dish_ingredient_path(dish_id: dish.id, id: ingredient.id), params: ingredient.to_json, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      ingredient.quantity = nil
      put api_dish_ingredient_path(dish_id: dish.id, id: ingredient.id), params: ingredient.to_json, headers: auth_header(user)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/dishes/:dish_id/ingredients/:id' do
    it 'should remove ingredient from dish' do
      delete api_dish_ingredient_path(dish_id: dish.id, id: ingredient.id), headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end
end
