# frozen_string_literal: true

module Api
  module V1
    module Dishes
      class IngredientsController < ApplicationController
        load_and_authorize_resource class: DishIngredient

        def index; end

        def show; end

        def create
          @ingredient = DishIngredient.new(create_params)
          if @ingredient.save
            render :show, status: :created
          else
            render json: @ingredient.errors.full_messages, status: :unprocessable_content
          end
        end

        def update
          if @ingredient.update(update_params)
            render :show, status: :ok
          else
            render json: @ingredient.errors.full_messages, status: :unprocessable_content
          end
        end

        def destroy
          @ingredient.destroy
        end

        protected

        def create_params
          params.permit(
            :quantity,
            :food_id,
            :dish_id
          )
        end

        def update_params
          params.permit(
            :quantity,
            :food_id
          )
        end
      end
    end
  end
end
