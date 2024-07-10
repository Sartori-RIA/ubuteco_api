# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ApplicationController
      load_and_authorize_resource

      def index
        @orders = Order.search params[:q] if params[:q].present?
        pagy_render @orders
      end

      def show; end

      def create
        Order.transaction do
          @order = Order.new(create_params)

          if @order.save
            render json: @order, status: :created
          else
            render json: @order.errors, status: :unprocessable_entity
          end
        end
      end

      def update
        render json: @order.errors, status: :unprocessable_entity unless @order.update(update_params)
      end

      def destroy
        @order.destroy
      end

      protected

      def create_params
        params.permit(
          :total, :total_with_discount, :status, :discount, :user, :user_id,
          :organization, :organization_id, :table_id
        )
      end

      def update_params
        params.permit(:total, :total_with_discount, :status, :discount, :user, :user_id, :table_id)
      end
    end
  end
end
