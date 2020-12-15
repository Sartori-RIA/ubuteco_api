# frozen_string_literal: true

module Api
  class DishesController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @dishes.order(name: :asc)
    end

    def show
      render json: @dish.to_json
    end

    def search
      @dishes = Dish.search params[:q]
      render json: @dishes.order(name: :asc)
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

    def dish_params
      params.permit(:name,
                    :price,
                    :image,
                    dish_ingredients_attributes: %i[
                      quantity
                      food
                      food_id
                      id
                    ]).merge(organization_id: current_user.organization_id)
    end
  end
end
