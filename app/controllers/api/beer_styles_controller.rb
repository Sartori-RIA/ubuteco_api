# frozen_string_literal: true

module Api
  class BeerStylesController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @beer_styles.order(name: :asc)
    end

    def show
      render json: @beer_style
    end

    def create
      @beer_style = BeerStyle.new(beer_style_params)

      if @beer_style.save
        render json: @beer_style, status: :created
      else
        render json: @beer_style.errors, status: :unprocessable_entity
      end
    end

    def update
      if @beer_style.update(beer_style_params)
        render json: @beer_style
      else
        render json: @beer_style.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @beer_style.destroy
    end

    private

    def beer_style_params
      params.permit(:name).merge(user: current_user)
    end
  end
end
