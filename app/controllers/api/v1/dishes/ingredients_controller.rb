# frozen_string_literal: true

module Api
  module V1
    module Dishes
      class IngredientsController < ApplicationController
        load_and_authorize_resource class: DishIngredient

        def index; end

        def create
          @ingredient = DishIngredient.new(create_params)
          if @ingredient.save
            render status: :created
          else
            render json: @ingredient.errors, status: :unprocessable_entity
          end
        end

        def update
          render json: @ingredient.errors, status: :unprocessable_entity unless @ingredient.update(update_params)
        end

        def destroy
          @ingredient.destroy
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
            :food_id
          )
        end
      end
    end
  end
end
