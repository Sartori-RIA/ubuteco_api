# frozen_string_literal: true

module Api
  class FoodsController < ApplicationController
    before_action :set_food, only: %i[show update destroy]
    before_action :authenticate_user!

    def index
      @foods = Food.where(user: current_user).order(name: :asc)

      render json: @foods
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

    def set_food
      @food = Food.find_by(id: params[:id], user: current_user)
    end

    def food_params
      params.permit(:name,
                    :price,
                    :quantity_stock,
                    :image,
                    :valid_until).merge(user: current_user)
    end
  end
end
