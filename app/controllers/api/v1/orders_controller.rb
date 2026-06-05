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
        preload_order_associations(@records)
      end

      def show
        @order = Order.includes(:table, :organization, :user).find(@order.id)
      end

      def create
        @order = Order.new(create_params)

        if @order.save
          render :show, status: :created
        else
          render_model_errors(@order)
        end
      end

      def update
        if @order.update(update_params)
          @order.recalculate_total if @order.saved_change_to_discount_cents?
          render :show, status: :ok
        else
          render_model_errors(@order)
        end
      end

      def destroy
        if @order.destroy
          head :no_content
        else
          render_model_errors(@order)
        end
      end

      protected

      def create_params
        base = params.permit(:status, :discount, :table_id)
        base.merge(organization_id: order_organization_id, user_id: current_user.id)
      end

      def order_organization_id
        return current_user.organization_id if current_user.organization_id.present?
        return params[:organization_id] if current_user.role.name == 'CUSTOMER'

        Current.organization_id
      end

      def preload_order_associations(records)
        return if records.blank?

        ActiveRecord::Associations::Preloader.new(records:, associations: %i[table organization user]).call
      end

      def update_params
        params.permit(:status, :discount, :table_id, :user_id)
      end
    end
  end
end
