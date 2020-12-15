# frozen_string_literal: true

module Api
  module Orders
    class ItemsController < ApplicationController
      load_and_authorize_resource class: OrderItem

      def index
        render json: @items
      end

      def create
        if OrderItem.already_exists_in_order(order_item_params)
          @item = OrderItem.find_by(item_id: order_item_params[:item_id])
          update
        else
          @item = OrderItem.new(order_item_params)
          if @item.save
            render json: @item, status: :created
          else
            render json: @item.errors, status: :unprocessable_entity
          end
        end
      end

      def update
        attributes = order_item_params
        attributes[:quantity] = @item.quantity + attributes[:quantity]
        if @item.update(attributes)
          render json: @item
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @item.destroy
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

      def already_exists_in_order(attributes)
        OrderItem.exists?(item_id: attributes[:item_id],
                          order_id: attributes[:order_id],
                          item_type: attributes[:item_type])
      end
    end
  end
end
