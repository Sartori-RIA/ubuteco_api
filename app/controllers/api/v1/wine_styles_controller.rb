# frozen_string_literal: true

module Api
  class V1::WineStylesController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @wine_styles.order(name: :asc)
    end

    def show
      render json: @wine_style
    end

    def create
      @wine_style = WineStyle.new(create_params)

      if @wine_style.save
        render json: @wine_style, status: :created
      else
        render json: @wine_style.errors, status: :unprocessable_entity
      end
    end

    def update
      if @wine_style.update(update_params)
        render json: @wine_style
      else
        render json: @wine_style.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @wine_style.destroy
    end

    def style_available?
      wine_style = WineStyle.find_by(name: params[:q])
      if wine_style.nil?
        render json: {}, status: :no_content
      else
        render json: {}, status: :ok
      end
    end

    private

    def create_params
      params.permit(:name)
    end

    def update_params
      params.permit(:name)
    end
  end
end
