# frozen_string_literal: true

module Api
  module V1
    class StockAdjustmentsController < ApplicationController
      before_action :set_product

      def update
        authorize! :adjust_stock, @product

        unless Inventory::AdjustStock.call(
          product: @product,
          adjustment: stock_params[:adjustment],
          reason: stock_params[:reason],
          user: current_user
        )
          return render_api_errors(adjust_stock_errors(@product))
        end

        render_stockable(@product)
      end

      private

      def set_product
        @product = Inventory.find_stockable!(product_type: params[:product_type], id: params[:id])
      end

      def stock_params
        params.permit(:adjustment, :reason)
      end

      def render_stockable(product)
        route_key = product.model_name.route_key
        param_key = product.model_name.param_key

        render partial: "api/v1/#{route_key}/#{param_key}",
               locals: { param_key.to_sym => product },
               formats: :json
      end

      ADJUST_STOCK_ERROR_CODES = {
        base: 'not_stockable',
        adjustment: 'adjustment_zero',
        quantity_stock: 'insufficient_stock'
      }.freeze

      def adjust_stock_errors(product)
        product.errors.map do |error|
          {
            code: ADJUST_STOCK_ERROR_CODES.fetch(error.attribute.to_sym, 'validation_error'),
            field: error.attribute.to_s,
            message: error.full_message
          }
        end
      end
    end
  end
end
