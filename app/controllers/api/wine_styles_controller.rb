# frozen_string_literal: true

module Api
  class WineStylesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_wine_style, only: %i[show update destroy]

    def index
      @wine_styles = WineStyle.where(user: current_user).order(name: :asc)
      render json: @wine_styles
    end

    def show
      render json: @wine_style
    end

    def create
      @wine_style = WineStyle.new(wine_style_params)

      if @wine_style.save
        render json: @wine_style, status: :created
      else
        render json: @wine_style.errors, status: :unprocessable_entity
      end
    end

    def update
      if @wine_style.update(wine_style_params)
        render json: @wine_style
      else
        render json: @wine_style.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @wine_style.destroy
    end

    private

    def set_wine_style
      @wine_style = WineStyle.find_by(id: params[:id], user: current_user)
    end

    def wine_style_params
      params.permit(:name).merge(user: current_user)
    end
  end
end
