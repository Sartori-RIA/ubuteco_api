# frozen_string_literal: true

module Api
  class V1::BeersController < ApplicationController
    load_and_authorize_resource

    def index
      @beers = paginate @beers.order(name: :asc), include: %i[beer_style maker]
    end

    def show; end

    def search
      @beers = Beer.search params[:q]
      @beers = paginate @beers.order(name: :asc), include: %i[beer_style maker]
    end

    def create
      @beer = Beer.new(create_params)

      if @beer.save
        render status: :created
      else
        render json: @beer.errors, status: :unprocessable_entity
      end
    end

    def update
      render json: @beer.errors, status: :unprocessable_entity unless @beer.update(update_params)
    end

    def destroy
      @beer.destroy
    end

    protected

    def create_params
      update_params.merge(organization_id: current_user.organization_id)
    end

    def update_params
      params.permit(
        :name, :description, :image, :maker_id, :maker, :beer_style_id, :beer_style, :price, :ibu,
        :quantity_stock, :abv, :user_id, :id, :price_cents, :price_currency, :deleted_at, :created_at,
        :updated_at, :valid_until
      )
    end
  end
end
