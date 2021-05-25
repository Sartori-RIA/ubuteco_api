# frozen_string_literal: true

module Api
  class V1::KitchensController < ApplicationController
    load_and_authorize_resource class: OrderItem

    def index
      @kitchens = paginate @kitchens.includes(:item).order(:created_at)
    end

    def update
      unless @kitchen.update(update_params)
        render json: @kitchen.errors, status: :unprocessable_entity
      end
    end

    protected

    def update_params
      params.permit(:id, :status)
    end
  end
end
