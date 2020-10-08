# frozen_string_literal: true

module Api
  class FoodsController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @foods.order(name: :asc)
    end

    def show
      render json: @foods
    end

    def create
      @foods = Food.new(food_params)

      if @foods.save
        render json: @foods, status: :created
      else
        render json: @foods.errors, status: :unprocessable_entity
      end
    end

    def update
      if @food.update(food_params)
        render json: @food
      else
        render json: @food.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @food.destroy
    end

    private

    def food_params
      params.permit(:name,
                    :price,
                    :quantity_stock,
                    :image,
                    :valid_until).merge(user: current_user)
    end
  end
end
