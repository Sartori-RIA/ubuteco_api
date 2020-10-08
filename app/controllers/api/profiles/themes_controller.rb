# frozen_string_literal: true

module Api
  module Profiles
    class ThemesController < ApplicationController
      load_and_authorize_resource

      def show
        render json: @theme
      end

      def update
        if @theme.update(theme_params)
          render json: @theme
        else
          render json: @theme.errors, status: :unprocessable_entity
        end
      end

      private

      def theme_params
        params.permit(:id,
                      :color_header,
                      :color_sidebar,
                      :color_footer,
                      :rtl)
              .merge(user: current_user)
      end
    end
  end
end
