# frozen_string_literal: true

module Api
  class WinesController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @wines.order(name: :asc), include: %i[wine_style maker]
    end

    def show
      render json: @wine.to_json
    end

    def search
      @wines = Wine.search params[:q]
      render json: @wines.order(name: :asc), include: %i[wine_style maker]
    end

    def create
      @wine = Wine.new(wine_params)
      if @wine.save
        render json: @wine.to_json, status: :created
      else
        render json: @wine.errors, status: :unprocessable_entity
      end
    end

    def update
      if @wine.update(wine_params)
        render json: @wine.to_json
      else
        render json: @wine.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @wine.destroy
    end

    private

    def wine_params
      params.permit(:name,
                    :quantity_stock,
                    :image,
                    :abv,
                    :price,
                    :description,
                    :maker,
                    :maker_id,
                    :vintage_wine,
                    :visual,
                    :user_id,
                    :id,
                    :ripening,
                    :grapes,
                    :wine_style,
                    :wine_style_id).merge(organization_id: current_user.organization_id)
    end
  end
end
