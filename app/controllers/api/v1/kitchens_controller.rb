# frozen_string_literal: true

module Api
  class V1::KitchensController < ApplicationController
    load_and_authorize_resource class: OrderItem

    include KitchensHelper

    def index
      @kitchens = @kitchens.includes(:item).order(:created_at)
      render json: @kitchens.map { |it| format_dish_to_make(it) }
    end

    def update
      if @kitchen.update(update_params)
        render json: format_dish_to_make(@kitchen)
      else
        render json: @kitchen.errors, status: :unprocessable_entity
      end
    end

    protected

    def update_params
      params.permit(:id, :status)
    end
  end
end
