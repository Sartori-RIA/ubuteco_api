# frozen_string_literal: true

module Api
  class KitchensController < ApplicationController
    before_action :set_order_item, only: [:update]
    before_action :authenticate_user!

    include KitchensHelper

    def index
      @dishes = OrderItem.where(
        item_type: :Dish,
        created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
      ).includes(:item).order(:created_at)
      @dishes = @dishes.map { |it| format_dish_to_make(it) }
      render json: @dishes
    end

    def update
      if @dish.update(kitchen_params)
        render json: format_dish_to_make(@dish)
      else
        render json: @dish.errors, status: :unprocessable_entity
      end
    end

    protected

    def kitchen_params
      params.permit(:id, :status)
    end

    def set_order_item
      @dish = OrderItem.find_by(id: params[:id])
    end
  end
end
