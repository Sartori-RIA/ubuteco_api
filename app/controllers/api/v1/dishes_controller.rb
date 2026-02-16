# frozen_string_literal: true

module Api
  module V1
    class DishesController < ApplicationController
      load_and_authorize_resource

      def index
        @dishes = Dish.pagy_search params[:q] if params[:q].present?
        pagy_render @dishes.includes(dish_ingredients: { include: :food }).order(name: :asc)
      end

      def show; end

      def create
        @dish = Dish.new(create_params)
        if @dish.save
          render :show, json: @dish, status: :created
        else
          render json: @dish.errors.full_messages, status: :unprocessable_content
        end
      end

      def update
        if @dish.update(update_params)
          render :show
        else
          render json: @dish.errors.full_messages, status: :unprocessable_content
        end
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
