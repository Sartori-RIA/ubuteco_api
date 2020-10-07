# frozen_string_literal: true

module Api
  class WinesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_wine, only: %i[show update destroy]

    def index
      @wines = Wine.where(user: current_user).order(name: :asc)
      render json: @wines, include: %i[wine_style maker]
    end

    def show
      render json: @wine.to_json
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

    def set_wine
      @wine = Wine.find_by(id: params[:id], user: current_user)
    end

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
                    :wine_style_id).merge(user: current_user)
    end
  end
end
