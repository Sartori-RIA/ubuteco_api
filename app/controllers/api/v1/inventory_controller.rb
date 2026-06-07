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
    end
  end
end
