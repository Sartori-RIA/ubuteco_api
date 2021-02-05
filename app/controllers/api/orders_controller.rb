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

    def search
      @orders = Order.search params[:q]
      paginate json: @orders, include: %i[table]
    end

    def create
      @order = Order.new(create_params)

      if @order.save
        render json: @order, status: :created
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end

    def update
      if @order.update(update_params)
        render json: @order
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @order.destroy
    end

    private

    def create_params
      params.permit(:total,
                    :total_with_discount,
                    :status,
                    :discount,
                    :user,
                    :user_id,
                    :organization,
                    :organization_id,
                    :table_id)
    end

    def update_params
      params.permit(:total,
                    :total_with_discount,
                    :status,
                    :discount,
                    :user,
                    :user_id,
                    :table_id)
    end
  end
end
