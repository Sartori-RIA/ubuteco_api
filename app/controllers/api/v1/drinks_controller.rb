# frozen_string_literal: true

module Api
  module V1
    class DrinksController < ApplicationController
      load_and_authorize_resource

      def index
        @drinks = Drink.search params[:q] if params[:q].present?
        pagy_render @drinks.order(name: :asc), %i[maker]
      end

      def show; end

      def create
        @drink = Drink.new(create_params)

        if @drink.save
          render json: @drink, status: :created
        else
          render json: @drink.errors, status: :unprocessable_entity
        end
      end

      def update
        render json: @drink.errors, status: :unprocessable_entity unless @drink.update(update_params)
      end

      def destroy
        @drink.destroy
      end

      protected

      def create_params
        update_params.merge(organization_id: current_user.organization_id)
      end

      def update_params
        params.permit(:name, :description, :image, :maker_id, :maker, :price, :quantity_stock, :flavor)
      end
    end
  end
end
