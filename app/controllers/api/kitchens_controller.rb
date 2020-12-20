# frozen_string_literal: true

module Api
  class KitchensController < ApplicationController
    load_and_authorize_resource

    include KitchensHelper

    def index
      @kitchens = @kitchens.includes(:item).order(:created_at)
      render json: @kitchens.map { |it| format_dish_to_make(it) }
    end

    def update
      if @dish.update(update_params)
        render json: format_dish_to_make(@dish)
      else
        render json: @dish.errors, status: :unprocessable_entity
      end
    end

    protected

    def update_params
      params.permit(:id, :status)
    end
  end
end
