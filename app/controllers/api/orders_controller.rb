# frozen_string_literal: true

module Api
  class OrdersController < ApplicationController
    before_action :set_order, only: %i[show update destroy]
    before_action :authenticate_user!

    # GET /orders
    def index
      @orders = Order.where(
        user: current_user,
        created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
      )

      render json: @orders, include: [:table]
    end

    # GET /orders/1
    def show
      render json: @order, include: %i[order_items table]
    end

    # POST /orders
    def create
      @order = Order.new(order_params)

      if @order.save
        render json: @order, status: :created
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /orders/1
    def update
      if @order.update(order_params)
        render json: @order
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end

    # DELETE /orders/1
    def destroy
      @order.destroy
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find_by(id: params[:id], user: current_user)
    end

    # Only allow a trusted parameter "white list" through.
    def order_params
      params.permit(:total,
                    :total_with_discount,
                    :discount,
                    :table_id).merge(user: current_user)
    end
  end
end
