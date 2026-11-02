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

      def restock_suggestions
        authorize! :read, :inventory

        payload = Inventory::RestockSuggestionsQuery.call(
          organization: current_user.organization,
          cover_days: cover_days_param,
          window_days: window_days_param
        )
        payload[:items] = explain_items(payload) if explain?

        render json: payload
      rescue ArgumentError
        render_api_errors(
          [{ code: 'validation_error', field: 'cover_days', message: I18n.t('api.errors.restock_range') }],
          status: :unprocessable_content
        )
      end

      private

      def explain_items(payload)
        return payload[:items] unless Ai.enabled_for?(current_user.organization)

        Inventory::RestockExplainer.call(
          organization: current_user.organization,
          items: payload[:items],
          cover_days: payload[:cover_days],
          window_days: payload[:window_days],
          user: current_user
        )
      end

      def cover_days_param
        params[:cover_days].presence || Inventory.restock_cover_days
      end

      def window_days_param
        params[:window_days].presence || Inventory.restock_window_days
      end

      def explain?
        ActiveModel::Type::Boolean.new.cast(params[:explain])
      end

      def include_expired?
        return true if params[:include_expired].nil?

        ActiveModel::Type::Boolean.new.cast(params[:include_expired]) != false
      end
    end
  end
end
