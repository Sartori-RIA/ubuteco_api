# frozen_string_literal: true

module Api
  class BeersController < ApplicationController
    before_action :set_beer, only: %i[show update destroy]
    before_action :authenticate_user!

    def index
      @beers = Beer.where(user: current_user).order(name: :asc)

      render json: @beers, include: %i[beer_style maker]
    end

    def show
      render json: @beer.to_json
    end

    def create
      @beer = Beer.new(beer_params)

      if @beer.save
        render json: @beer.to_json, status: :created
      else
        render json: @beer.errors, status: :unprocessable_entity
      end
    end

    def update
      if @beer.update(beer_params)
        render json: @beer.to_json
      else
        render json: @beer.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @beer.destroy
    end

    private

    def set_beer
      @beer = Beer.find_by(id: params[:id], user: current_user)
    end

    def beer_params
      params.permit(:name,
                    :description,
                    :image,
                    :maker_id,
                    :maker,
                    :beer_style_id,
                    :beer_style,
                    :price,
                    :ibu,
                    :quantity_stock,
                    :abv,
                    :user_id,
                    :id,
                    :price_cents,
                    :price_currency,
                    :deleted_at,
                    :created_at,
                    :updated_at,
                    :valid_until).merge(user: current_user)
    end
  end
end
