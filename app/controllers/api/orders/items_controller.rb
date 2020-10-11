# frozen_string_literal: true

module Api
  module Orders
    class ItemsController < ApplicationController
      authorize_resource class: OrderItem
      before_action :set_order_item, only: %i[update destroy]

      def index
        @order_items = OrderItem.where(order_id: params[:order_id])
        render json: @order_items
      end

      def create
        @order_item = OrderItem.new(order_item_params)
        if @order_item.save
          render json: @order_item, status: :created
        else
          render json: @order_item.errors, status: :unprocessable_entity
        end
      end

      def update
        if @order_item.update(quantity: params[:quantity])
          render json: @order_item
        else
          render json: @order_item.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @order_item.destroy
        render json: {
          message: 'Item deleted from order',
          id: params[:id],
          order_id: params[:order_id]
        }, status: :ok
      end

      private

      def order_item_params
        params.permit(:item_type, :item_id, :quantity, :order_id)
      end

      def set_order_item
        @order_item = OrderItem.find_by(id: params[:id])
      end

      # noinspection RubyCaseWithoutElseBlockInspection
      def set_item
        case params[:item_type]
        when 'Beer'
          @item = Beer.find_by(id: params[:item_id], user: current_user)
        when 'Dish'
          @item = Dish.find_by(id: params[:item_id], user: current_user)
        when 'Drink'
          @item = Drink.find_by(id: params[:item_id], user: current_user)
        when 'Wine'
          @item = Wine.find_by(id: params[:item_id], user: current_user)
        end
      end
    end
  end
end
