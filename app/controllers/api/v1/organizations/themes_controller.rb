# frozen_string_literal: true

module Api
  module V1
    module Organizations
      class ThemesController < ApplicationController
        load_and_authorize_resource

        def index; end

        def show; end

        def update
          if @theme.update(update_params)
            render :show, status: :ok
          else
            render json: @theme.errors.full_messages, status: :unprocessable_content
          end
        end

        protected

        def update_params
          params.permit(:color_header, :color_sidebar, :color_footer, :rtl)
                .merge(organization_id: current_user.organization_id)
        end
      end
    end
  end
end
