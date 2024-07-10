# frozen_string_literal: true

module Api
  module V1
    class DishesController < ApplicationController
      load_and_authorize_resource

      def index
        @dishes = Dish.search params[:q] if params[:q].present?
        pagy_render @dishes.order(name: :asc), [dish_ingredients: { include: :food }]
      end

      def show; end

      def create
        @dish = Dish.new(create_params)
        if @dish.save
          render json: @dish, status: :created
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
end
