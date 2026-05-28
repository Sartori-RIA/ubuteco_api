# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ApplicationController
      load_and_authorize_resource except: :index

      def index
        authorize! :read, Order
        extra_where = {}
        if params[:status].present? && Order.statuses.key?(params[:status])
          extra_where[:status] = params[:status]
        end
        @pagy, @records = pagy_search_authorized(Order, extra_where:)
      end

      def show; end

      def create
        @order = Order.new(create_params)

        if @order.save
          render :show, status: :created
        else
          render json: @order.errors.full_messages, status: :unprocessable_content
        end
      end

      def update
        if @order.update(update_params)
          @order.recalculate_total if @order.saved_change_to_discount_cents?
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
        base = params.permit(:status, :discount, :table_id, :organization_id)
        org_id = base.delete(:organization_id) || current_user.organization_id
        base.merge(organization_id: org_id, user_id: current_user.id)
      end

      def update_params
        params.permit(:status, :discount, :table_id, :user_id)
      end
    end
  end
end
