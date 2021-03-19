# frozen_string_literal: true

module Api
  module Orders
    class ItemsController < ApplicationController
      load_and_authorize_resource class: OrderItem

      def index
        render json: @items, include: :item
      end

      def create
        @item = OrderItem.new(create_params)
        if @item.save
          unless @item.item_type == "Dish"
            @item.item.update(quantity_stock: @item.item.quantity_stock - @item.quantity)
          end
          render status: :created
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      end

      def update
        diff = @item.quantity - update_params[:quantity]
        if @item.update(update_params)
          @item.update_stock(diff: diff, is_quantity_lower: is_quantity_lower?)
          render include: :item
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

      def create_params
        params.permit(:item_type, :item_id, :quantity, :order_id, :id)
      end

      def update_params
        params.permit(:item_type, :item_id, :quantity)
      end

      def is_quantity_lower?
        @item.quantity < update_params[:quantity]
      end
    end
  end
end
