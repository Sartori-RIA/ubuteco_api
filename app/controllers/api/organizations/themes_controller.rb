# frozen_string_literal: true

module Api
  module Organizations
    class ThemesController < ApplicationController
      load_and_authorize_resource

      def index
        render json: @themes
      end

      def show
        render json: @theme
      end

      def update
        if @theme.update(update_params)
          render json: @theme
        else
          render json: @theme.errors, status: :unprocessable_entity
        end
      end

      private

      def update_params
        params.permit(:id,
                      :color_header,
                      :color_sidebar,
                      :color_footer,
                      :rtl)
              .merge(organization_id: current_user.organization_id)
      end
    end
  end
end
