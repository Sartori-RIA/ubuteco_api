# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ApplicationController
      load_and_authorize_resource except: :index

      def index
        authorize! :read, Order
        @pagy, @records = pagy_search_authorized(Order)
      end

      def show; end

      def create
        Order.transaction do
          @order = Order.new(create_params)

          if @order.save
            render :show, status: :created
          else
            render json: @order.errors.full_messages, status: :unprocessable_content
          end
        end
      end

      def update
        if @order.update(update_params)
          render :show, status: :ok
        else
          render json: @order.errors.full_messages, status: :unprocessable_content
        end
      end

      def destroy
        if @order.destroy
          head :no_content
        else
          render json: @order.errors.full_messages, status: :unprocessable_content
        end
      end

      protected

      def create_params
        params.permit(
          :total, :total_with_discount, :status, :discount, :user, :user_id,
          :organization, :organization_id, :table_id
        )
      end

      def update_params
        params.permit(:total, :total_with_discount, :status, :discount, :user, :user_id, :table_id)
      end
    end
  end
end
