# frozen_string_literal: true

module Api
  class DishesController < ApplicationController
    before_action :set_dish, only: %i[show update destroy]
    before_action :authenticate_user!

    def index
      @dishes = Dish.where(user: current_user).order(name: :asc)

      render json: @dishes
    end

    def show
      render json: @dish.to_json
    end

    def create
      @dish = Dish.new(dish_params)
      if @dish.save
        render json: @dish.to_json, status: :created
      else
        render json: @dish.errors, status: :unprocessable_entity
      end
    end

    def update
      if @dish.update(dish_params)
        render json: @dish.to_json
      else
        render json: @dish.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @dish.destroy
    end

    private

    def set_dish
      @dish = Dish.includes([:dish_ingredients])
                  .find_by(id: params[:id], user: current_user)
    end

    def dish_params
      params.permit(:name,
                    :price,
                    :image,
                    dish_ingredients_attributes: %i[
                      quantity
                      food
                      food_id
                      id
                    ]).merge(user: current_user)
    end
  end
end
