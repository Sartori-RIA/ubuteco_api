# frozen_string_literal: true

module Api
  module Dishes
    class IngredientsController < ApplicationController
      load_and_authorize_resource class: DishIngredient

      def index
        render json: @ingredients
      end

      def create
        attributes = create_params
        if DishIngredient.exists?(id: attributes[:id])
          @ingredient = DishIngredient.find_by(id: attributes[:id])
          update
        else
          @ingredient = DishIngredient.new(create_params)
          if @ingredient.save
            render json: @ingredient, status: :created
          else
            render json: @ingredient.errors, status: :unprocessable_entity
          end
        end
      end

      def update
        attributes = update_params
        attributes[:quantity] = @ingredient.quantity + attributes[:quantity]
        if @ingredient.update(attributes)
          render json: @ingredient
        else
          render json: @ingredient.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @ingredient.destroy
        render json: {
          message: 'Ingredient deleted from dish',
          id: params[:id],
          dish_id: params[:dish_id]
        }, status: :ok
      end

      protected

      def create_params
        params.permit(
          :id,
          :quantity,
          :food_id,
          :dish_id
        )
      end

      def update_params
        params.permit(
          :id,
          :quantity,
          :food_id,
        )
      end
    end
  end
end
