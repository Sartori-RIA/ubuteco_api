# frozen_string_literal: true

module Api
  class V1::DishesController < ApplicationController
    load_and_authorize_resource

    def index
      @dishes = paginate @dishes.order(name: :asc), include: [dish_ingredients: { include: :food }]
    end

    def show; end

    def search
      @dishes = Dish.search params[:q]
      @dishes = paginate @dishes.order(name: :asc)
    end

    def create
      @dish = Dish.new(create_params)
      if @dish.save
        render status: :created
      else
        render json: @dish.errors, status: :unprocessable_entity
      end
    end

    def update
      render json: @dish.errors, status: :unprocessable_entity unless @dish.update(update_params)
    end

    def destroy
      @dish.destroy
    end

    protected

    def create_params
      update_params.merge(organization_id: current_user.organization_id)
    end

    def update_params
      params.permit(:name, :price, :image, dish_ingredients_attributes: %i[quantity food food_id id])
    end
  end
end
