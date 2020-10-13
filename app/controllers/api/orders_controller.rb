# frozen_string_literal: true

module Api
  class OrdersController < ApplicationController
    load_and_authorize_resource

    def index
      @orders = Order.where(
          user: current_user,
          created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
      )
      paginate json: @orders, include: [:table]
    end

    def show
      render json: @order, include: %i[order_items table]
    end

    def search
      @orders = Order.search params[:q]
      render json: @orders, include: %i[table]
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
                    :status,
                    :discount,
                    :table_id).merge(user_id: current_user.id)
    end
  end
end
