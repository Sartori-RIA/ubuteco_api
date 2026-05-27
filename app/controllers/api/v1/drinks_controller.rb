# frozen_string_literal: true

module Api
  module V1
    class DrinksController < ApplicationController
      load_and_authorize_resource except: :index

      def index
        authorize! :read, Drink
        @pagy, @records = pagy_search_authorized(Drink)
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
        if @drink.destroy
          head :no_content
        else
          render json: @drink.errors.full_messages, status: :unprocessable_content
        end
      end

      protected

      def create_params
        update_params.merge(organization_id: current_user.organization_id)
      end

      def update_params
        params.permit(:name, :description, :image, :maker, :price, :quantity_stock, :flavor)
      end
    end
  end
end
