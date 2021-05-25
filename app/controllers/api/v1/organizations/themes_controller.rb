# frozen_string_literal: true

module Api
  module V1::Organizations
    class ThemesController < ApplicationController
      load_and_authorize_resource

      def index; end

      def show; end

      def update
        unless @theme.update(update_params)
          render json: @theme.errors, status: :unprocessable_entity
        end
      end

      private

      def update_params
        params.merge(organization_id: current_user.organization_id)
        params.permit(:id,
                      :color_header,
                      :color_sidebar,
                      :color_footer,
                      :organization_id,
                      :rtl)
      end
    end
  end
end
