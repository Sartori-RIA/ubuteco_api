# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class IntakeController < ApplicationController
        def label
          authorize! :intake, :inventory
          raise Ai::DisabledError unless Ai.enabled_for?(Current.organization)

          upload = ::Inventory::Intake::Upload.new(params[:file], allowed: ::Inventory::Intake::Upload::IMAGES)
          render json: ::Catalog::Intake::LabelExtractor.call(
            organization: Current.organization,
            user: current_user,
            bytes: upload.image_bytes,
            media_type: upload.media_type,
            product_type: params[:product_type].to_s
          )
        rescue ::Inventory::Intake::Upload::Invalid, ArgumentError
          invalid_document
        end

        private

        def invalid_document
          render_api_errors(
            [{ code: 'invalid_document', message: I18n.t('api.errors.invalid_document') }],
            status: :unprocessable_content
          )
        end
      end
    end
  end
end
