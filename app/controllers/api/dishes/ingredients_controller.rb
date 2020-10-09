# frozen_string_literal: true

module Api
  module Dishes
    class IngredientsController < ApplicationController
      load_and_authorize_resource class: DishIngredient
      before_action :set_dish
      before_action :set_food, only: %i[create]
      before_action :set_dish_ingredient, only: %i[update destroy]

      def index
        @dish_ingredients = DishIngredient.where(dish_id: @dish.id)
        render json: @dish_ingredients
      end

      def create
        @dish_ingredient = DishIngredient.new(dish_ingredient_params)
        if @dish_ingredient.save
          render json: @dish_ingredient, status: :created
        else
          render json: @dish_ingredient.errors, status: :unprocessable_entity
        end
      end

      def update
        if @dish_ingredient.update(dish_ingredient_params)
          render json: @dish_ingredient
        else
          render json: @dish_ingredient.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @dish_ingredient.destroy
        render json: {
          message: 'Ingredient deleted from dish',
          id: params[:id],
          dish_id: params[:dish_id]
        }, status: :ok
      end

      protected

      def set_dish
        @dish = Dish.find_by(id: params[:dish_id])
      end

      def set_dish_ingredient
        @dish_ingredient = DishIngredient.find_by(id: params[:id])
      end

      def set_food
        @food = Food.find_by(id: params[:food_id])
      end

      def dish_ingredient_params
        params.permit(
          :quantity,
          :food,
          :food_id,
          :dish,
          :dish_id,
          :id
        )
      end
    end
  end
end
