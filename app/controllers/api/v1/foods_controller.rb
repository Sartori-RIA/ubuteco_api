# frozen_string_literal: true

module Api
  module V1
    class FoodsController < ApplicationController
      load_and_authorize_resource

      def index
        search = Food.pagy_search(params[:q].presence || "*", page: params[:page], per_page: 20)
        @pagy, @records = pagy(:searchkick, search)
      end

      def show; end

      def create
        @food = Food.new(create_params)

        if @food.save
          render :show, status: :created
        else
          render json: @food.errors.full_messages, status: :unprocessable_content
        end
      end

      def update
        if @food.update(update_params)
          render :show, status: :ok
        else
          render json: @food.errors.full_messages, status: :unprocessable_content
        end
      end

      def destroy
        if @food.destroy
          head :no_content
        else
          render json: @food.errors.full_messages, status: :unprocessable_content
        end
      end

      protected

      def create_params
        update_params.merge(organization_id: current_user.organization_id)
      end

      def update_params
        params.permit(:name, :price, :quantity_stock, :image, :valid_until)
      end
    end
  end
end
