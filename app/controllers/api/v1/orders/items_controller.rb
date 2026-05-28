# frozen_string_literal: true

module Api
  module V1
    module Orders
      class ItemsController < ApplicationController
        load_and_authorize_resource class: OrderItem, except: %i[create index]

        before_action :set_order, only: %i[index create]

        def index
          authorize! :read, @order
          @items = @order.order_items.includes(:item)
        end

        def show; end

        def create
          authorize! :create, OrderItem.new(order: @order)
          @item = @order.order_items.build(create_params)

          if @item.save
            @item = OrderItem.includes(:item).find(@item.id)
            render :show, status: :created
          else
            render json: @item.errors.full_messages, status: :unprocessable_content
          end
        rescue OrderItem::InsufficientStock
          render json: ['Insufficient stock'], status: :unprocessable_content
        end

        def update
          previous_quantity = @item.quantity

          OrderItem.transaction do
            unless @item.update(update_params)
              render json: @item.errors.full_messages, status: :unprocessable_content
              raise ActiveRecord::Rollback
            end

            @item.apply_quantity_change!(previous_quantity:)
          end

          return if performed?

          @item = OrderItem.includes(:item).find(@item.id)
          render :show, status: :ok
        rescue OrderItem::InsufficientStock
          render json: ['Insufficient stock'], status: :unprocessable_content
        end

        def destroy
          if @item.destroy
            head :no_content
          else
            render json: @item.errors.full_messages, status: :unprocessable_content
          end
        end

        protected

        def set_order
          @order = Order.accessible_by(current_ability, :read).find(params[:order_id])
        end

        def create_params
          params.permit(:item_type, :item_id, :quantity)
        end

        def update_params
          params.permit(:quantity, :status)
        end
      end
    end
  end
end
