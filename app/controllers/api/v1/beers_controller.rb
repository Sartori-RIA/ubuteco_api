# frozen_string_literal: true

module Api
  module V1
    class BeersController < ApplicationController
      load_resource

      def index
        @beers = Beer.pagy_search params[:q] if params[:q].present?
        pagy_render @beers.includes(:maker, :beer_style).order(name: :asc)
      end

      def show; end

      def create
        @beer = Beer.new(create_params)

        if @beer.save
          render :show, status: :created
        else
          render json: @beer.errors.full_messages, status: :unprocessable_content
        end
      end

      def update
        if @beer.update(update_params)
          render :show, status: :ok
        else
          render json: @beer.errors.full_messages, status: :unprocessable_content
        end
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
          :quantity_stock, :abv, :price_cents, :price_currency, :valid_until
        )
      end
    end
  end
end
