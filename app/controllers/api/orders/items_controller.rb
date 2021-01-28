# frozen_string_literal: true

module Api
  module Orders
    class ItemsController < ApplicationController
      load_and_authorize_resource class: OrderItem
      include OrdersHelper

      def index
        render json: @items
      end

      def create
        if already_exists_in_order?(create_params)
          @item = OrderItem.find_by(order_id: create_params[:id], item_id: create_params[:item_id])
          update
        else
          @item = OrderItem.new(create_params)
          if @item.save
            render json: @item, status: :created
          else
            render json: @item.errors, status: :unprocessable_entity
          end
        end
      end

      def update
        attributes = update_params
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

      def create_params
        params.permit(:item_type, :item_id, :quantity, :order_id, :id)
      end

      def update_params
        params.permit(:item_type, :item_id, :quantity)
      end
    end
  end
end
