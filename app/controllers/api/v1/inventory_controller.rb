# frozen_string_literal: true

module Api
  module V1
    class InventoryController < ApplicationController
      def low_stock
        authorize! :read, :inventory

        items = Inventory::LowStockQuery.call(organization_id: current_user.organization_id)

        render json: {
          threshold: Inventory.low_stock_threshold,
          items:
        }
      end

      def expiring
        authorize! :read, :inventory

        items = Inventory::ExpiringProductsQuery.call(
          organization: current_user.organization,
          include_expired: include_expired?
        )

        render json: {
          warning_days: Inventory.expiry_warning_days,
          items:
        }
      end

      private

      def include_expired?
        return true if params[:include_expired].nil?

        ActiveModel::Type::Boolean.new.cast(params[:include_expired]) != false
      end
    end
  end
end
