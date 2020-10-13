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
        attributes = order_item_params
        if already_exists_in_order(attributes)
          @order_item = OrderItem.find_by(item_id: attributes[:item_id])
          update
        else
          @order_item = OrderItem.new(order_item_params)
          if @order_item.save
            render json: @order_item, status: :created
          else
            render json: @order_item.errors, status: :unprocessable_entity
          end
        end
      end

      def update
        attributes = order_item_params
        attributes[:quantity] = @order_item.quantity + attributes[:quantity]
        if @order_item.update(attributes)
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

      def already_exists_in_order(attributes)
        OrderItem.exists?(item_id: attributes[:item_id],
                          order_id: attributes[:order_id],
                          item_type: attributes[:item_type])
      end
    end
  end
end
