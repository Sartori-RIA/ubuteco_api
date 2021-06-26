# frozen_string_literal: true

module Api
  class V1::FoodsController < ApplicationController
    load_and_authorize_resource

    def index
      @foods = paginate @foods.order(name: :asc)
    end

    def show; end

    def search
      @foods = Food.search params[:q]
      @foods = paginate @foods.order(name: :asc)
    end

    def create
      @food = Food.new(create_params)

      if @food.save
        render status: :created
      else
        render json: @food.errors, status: :unprocessable_entity
      end
    end

    def update
      render json: @food.errors, status: :unprocessable_entity unless @food.update(update_params)
    end

    def destroy
      @food.destroy
    end

    protected

    def create_params
      update_params.merge(organization_id: current_user.organization_id)
    end

    def update_params
      params.permit(:name, :price, :quantity_stock, :image, :valid_until)
    end
  end
end
