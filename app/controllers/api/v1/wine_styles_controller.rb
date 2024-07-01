# frozen_string_literal: true

module Api
  module V1
    class WineStylesController < ApplicationController
      load_and_authorize_resource

      def index
        render json: @wine_styles.order(name: :asc), status: :ok
      end

      def show; end

      def create
        @wine_style = WineStyle.new(create_params)

        if @wine_style.save
          render status: :created
        else
          render json: @wine_style.errors, status: :unprocessable_entity
        end
      end

      def update
        render json: @wine_style.errors, status: :unprocessable_entity unless @wine_style.update(update_params)
      end

      def destroy
        @wine_style.destroy
      end

      def style_available?
        wine_style = WineStyle.find_by(name: params[:q])
        if wine_style.blank?
          render json: {}, status: :no_content
        else
          render json: {}, status: :ok
        end
      end

      private

      def create_params
        params.permit(:name)
      end

      def update_params
        params.permit(:name)
      end
    end
  end
end
