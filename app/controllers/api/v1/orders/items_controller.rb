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
          @item = ::Orders::AddItem.call(order: @order, params: create_params)

          if @item.persisted?
            @item = OrderItem.includes(:item).find(@item.id)
            render :show, status: :created
          else
            render_model_errors(@item)
          end
        rescue OrderItem::InsufficientStock
          render_i18n_api_error(:insufficient_stock)
        end

        def update
          @item = ::Orders::UpdateItem.call(order_item: @item, params: update_params)

          if @item.errors.empty?
            @item = OrderItem.includes(:item).find(@item.id)
            render :show, status: :ok
          else
            render_model_errors(@item)
          end
        end

        def destroy
          if ::Orders::RemoveItem.call(order_item: @item)
            head :no_content
          else
            render_model_errors(@item)
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
