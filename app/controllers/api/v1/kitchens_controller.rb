# frozen_string_literal: true

module Api
  module V1
    class KitchensController < ApplicationController
      load_and_authorize_resource class: OrderItem

      def index
        @kitchens = @kitchens.includes(:item).order(:created_at)
      end

      def show; end

      def update
        if @kitchen.update(update_params)
          render :show, status: :ok
        else
          render json: @kitchen.errors.full_messages, status: :unprocessable_content
        end
      end

      protected

      def update_params
        params.permit(:status)
      end
    end
  end
end
