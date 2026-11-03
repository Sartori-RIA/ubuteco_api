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

      def nfe
        authorize! :intake, :inventory
        upload = Inventory::Intake::Upload.new(params[:file], allowed: Inventory::Intake::Upload::XML)
        lines = Inventory::Intake::NfeXmlParser.call(upload.bytes)
        render json: { lines: Inventory::Intake::Matcher.call(organization: Current.organization, lines:) }
      rescue Inventory::Intake::Upload::Invalid, Inventory::Intake::NfeXmlParser::Invalid
        invalid_document
      end

      def document
        authorize! :intake, :inventory
        raise Ai::DisabledError unless Ai.enabled_for?(Current.organization)

        upload = Inventory::Intake::Upload.new(params[:file], allowed: Inventory::Intake::Upload::DOCUMENTS)
        lines = Inventory::Intake::DocumentExtractor.call(
          organization: Current.organization,
          user: current_user,
          bytes: upload.image_bytes,
          media_type: upload.media_type
        )
        render json: { lines: Inventory::Intake::Matcher.call(organization: Current.organization, lines:) }
      rescue Inventory::Intake::Upload::Invalid
        invalid_document
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

      def invalid_document
        render_api_errors(
          [{ code: 'invalid_document', message: I18n.t('api.errors.invalid_document') }],
          status: :unprocessable_content
        )
      end
    end
  end
end
