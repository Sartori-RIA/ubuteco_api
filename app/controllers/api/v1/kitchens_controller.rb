# frozen_string_literal: true

module Api
  module V1
    class KitchensController < ApplicationController
      load_and_authorize_resource class: OrderItem

      def index
        @kitchens = @kitchens.includes(:item).order(:created_at)
      end

      def update
        render json: @kitchen.errors, status: :unprocessable_content unless @kitchen.update(update_params)
      end

      protected

      def update_params
        params.permit(:id, :status)
      end
    end
  end
end
