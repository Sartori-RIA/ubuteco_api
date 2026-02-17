# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ApplicationController
      load_and_authorize_resource

      def index
        search = Order.pagy_search(params[:q].presence || "*", page: params[:page], per_page: 20)
        @pagy, @records = pagy(:searchkick, search)
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
        @order.destroy
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
