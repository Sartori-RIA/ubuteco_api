# frozen_string_literal: true

module Api
  class BeerStylesController < ApplicationController
    load_and_authorize_resource

    def index
      @beer_styles = paginate @beer_styles.order(name: :asc)
    end

    def show; end

    def create
      @beer_style = BeerStyle.new(create_params)
      if @beer_style.save
        render status: :created
      else
        render json: @beer_style.errors, status: :unprocessable_entity
      end
    end

    def update
      if @beer_style.update(update_params)
        render status: :ok
      else
        render json: @beer_style.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @beer_style.destroy
    end

    def style_available?
      beer_style = BeerStyle.find_by(name: params[:q])
      if beer_style.blank?
        render json: {}, status: :no_content
      else
        render json: {}, status: :ok
      end
    end

    protected

    def create_params
      update_params
    end

    def update_params
      params.permit(:name)
    end
  end
end
