# frozen_string_literal: true

module Api
  class OrdersController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @orders, include: [:table]
    end

    def show
      render json: @order, include: %i[order_items table]
    end

    def create
      @order = Order.new(order_params)

      if @order.save
        render json: @order, status: :created
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end

    def update
      if @order.update(order_params)
        render json: @order
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @order.destroy
    end

    private

    def order_params
      params.permit(:total,
                    :total_with_discount,
                    :discount,
                    :table_id).merge(user: current_user)
    end
  end
end
