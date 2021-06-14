# frozen_string_literal: true

module Api
  module V1::Orders
    class ItemsController < ApplicationController
      load_and_authorize_resource class: OrderItem

      def index; end

      def create
        @item = OrderItem.new(create_params)
        if @item.save
          render status: :created
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      end

      def update
        diff = @item.quantity - update_params[:quantity]
        if @item.update(update_params)
          is_lower = @item.quantity_lower?(new_quantity: update_params[:quantity])
          @item.update_stock(diff: diff, is_quantity_lower: is_lower) unless @item.dish?
          render status: :ok
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @item.destroy
      end

      protected

      def create_params
        params.permit(:item_type, :item_id, :quantity, :order_id, :id)
      end

      def update_params
        params.permit(:item_type, :item_id, :quantity, :item)
      end
    end
  end
end
