# frozen_string_literal: true

module Api
  module V1
    class WineStylesController < ApplicationController
      load_and_authorize_resource

      def index; end

      def show; end

      def create
        @wine_style = WineStyle.new(create_params)

        if @wine_style.save
          render :show, status: :created
        else
          render json: @wine_style.errors.full_messages, status: :unprocessable_content
        end
      end

      def update
        if @wine_style.update(update_params)
          render :show
        else
          render json: @wine_style.errors.full_messages, status: :unprocessable_content
        end
      end

      def destroy
        @wine_style.destroy
      end

      def style_available?
        wine_style = WineStyle.find_by(name: params[:q])
        if wine_style.blank?
          head :no_content
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
