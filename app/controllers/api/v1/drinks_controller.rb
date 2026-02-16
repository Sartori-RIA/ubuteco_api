# frozen_string_literal: true

module Api
  module V1
    class DrinksController < ApplicationController
      load_and_authorize_resource

      def index
        @drinks = Drink.pagy_search params[:q] if params[:q].present?
        pagy_render @drinks.includes(:maker).order(name: :asc)
      end

      def show; end

      def create
        @drink = Drink.new(create_params)

        if @drink.save
          render :show, status: :created
        else
          render json: @drink.errors.full_messages, status: :unprocessable_content
        end
      end

      def update
        if @drink.update(update_params)
          render :show, status: :ok
        else
          render json: @drink.errors.full_messages, status: :unprocessable_content
        end
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
