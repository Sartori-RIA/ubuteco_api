# frozen_string_literal: true

module Api
  class DrinksController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @drinks.order(name: :asc), include: %i[maker]
    end

    def show
      render json: @drink, include: %i[maker]
    end

    def search
      @drinks = Drink.search params[:q]
      render json: @drinks.order(name: :asc), include: %i[maker]
    end

    def create
      @drink = Drink.new(drink_params)

      if @drink.save
        render json: @drink, status: :created
      else
        render json: @drink.errors, status: :unprocessable_entity
      end
    end

    def update
      if @drink.update(drink_params)
        render json: @drink
      else
        render json: @drink.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @drink.destroy
    end

    private

    def drink_params
      params.permit(:name,
                    :description,
                    :image,
                    :maker_id,
                    :maker,
                    :price,
                    :quantity_stock,
                    :flavor).merge(user: current_user)
    end
  end
end
