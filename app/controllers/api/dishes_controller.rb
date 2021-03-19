# frozen_string_literal: true

module Api
  class DishesController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @dishes.order(name: :asc), include: [dish_ingredients: { include: :food }]
    end

    def show
      render json: @dish, include: [dish_ingredients: { include: :food }]
    end

    def search
      @dishes = Dish.search params[:q]
      paginate json: @dishes.order(name: :asc)
    end

    def create
      @dish = Dish.new(create_params)
      if @dish.save
        render json: @dish, include: [dish_ingredients: { include: :food }], status: :created
      else
        render json: @dish.errors, status: :unprocessable_entity
      end
    end

    def update
      if @dish.update(update_params)
        render json: @dish, include: [dish_ingredients: { include: :food }]
      else
        render json: @dish.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @dish.destroy
    end

    private

    def create_params
      update_params.merge(organization_id: current_user.organization_id)
    end

    def update_params
      params.permit(
        :name,
        :price,
        :image,
        dish_ingredients_attributes: %i[
          quantity
          food
          food_id
          id
        ]
      )
    end
  end
end
