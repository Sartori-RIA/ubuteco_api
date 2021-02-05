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
      paginate json: @wines.order(name: :asc), include: %i[wine_style maker]
    end

    def create
      @wine = Wine.new(create_params)
      if @wine.save
        render json: @wine.to_json, status: :created
      else
        render json: @wine.errors, status: :unprocessable_entity
      end
    end

    def update
      if @wine.update(update_params)
        render json: @wine.to_json
      else
        render json: @wine.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @wine.destroy
    end

    private

    def create_params
      update_params.merge(organization_id: current_user.organization_id)
    end

    def update_params
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
                    :wine_style_id)
    end
  end
end
