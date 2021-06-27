# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Dishes::IngredientsController, type: :request do
  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @foods = create_list(:food, 5, organization: @organization)
    @dishes = create_list(:dish, 5, :with_ingredients, organization: @organization)
  end

  describe '#GET /api/dishes/:dish_id/ingredients' do
    let!(:dish) { @dishes.sample }

    it 'requests all dish ingredients' do
      get api_v1_dish_ingredients_path(dish_id: dish.id), headers: auth_header(@admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#POST /api/dishes/:dish_id/ingredients' do
    let!(:dish) { @dishes.sample }

    it 'adds ingredient to dish' do
      attributes = attributes_for(:dish_ingredient).merge(
        food_id: @foods.sample.id
      )
      post api_v1_dish_ingredients_path(dish_id: dish.id), params: attributes.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(:created)
    end

    it 'throws error with invalid params' do
      post api_v1_dish_ingredients_path(dish_id: dish.id), headers: auth_header(@admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#PUT /api/dishes/:dish_id/ingredients/:id' do
    let!(:dish) { @dishes.sample }
    let!(:ingredient) { dish.dish_ingredients.sample }

    it 'updates a dish ingredient' do
      ingredient.quantity = 10
      put api_v1_dish_ingredient_path(
        dish_id: dish.id,
        id: ingredient.id
      ),
          params: ingredient.to_json,
          headers: auth_header(@admin)
      expect(response).to have_http_status(:ok)
    end

    it 'throws error with invalid params' do
      ingredient.quantity = 0
      put api_v1_dish_ingredient_path(
        dish_id: dish.id,
        id: ingredient.id
      ),
          params: ingredient.to_json,
          headers: auth_header(@admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/dishes/:dish_id/ingredients/:id' do
    let!(:dish) { @dishes.sample }
    let!(:ingredient) { dish.dish_ingredients.sample }

    it 'removes ingredient from dish' do
      delete api_v1_dish_ingredient_path(dish_id: ingredient.dish_id, id: ingredient.id), headers: auth_header(@admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
