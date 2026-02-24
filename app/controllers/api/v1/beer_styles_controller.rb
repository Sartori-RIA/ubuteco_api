# frozen_string_literal: true

module Api
  module V1
    class BeerStylesController < ApplicationController
      load_and_authorize_resource

      def index
        @beer_styles = BeerStyle.search(params[:q]) if params[:q].present?
      end

      def show; end

      def create
        @beer_style = BeerStyle.new(create_params)
        if @beer_style.save
          render :show, status: :created
        else
          render json: @beer_style.errors.full_messages, status: :unprocessable_content
        end
      end

      def update
        if @beer_style.update(update_params)
          render :show, status: :ok
        else
          render json: @beer_style.errors.full_messages, status: :unprocessable_content
        end
      end

      def destroy
        if @beer_style.destroy
          head :no_content
        else
          render json: @beer_style.errors.full_messages, status: :unprocessable_content
        end
      end

      def style_available?
        BeerStyle.exists?(name: params[:q]) ? head(:ok) : head(:no_content)
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
end
