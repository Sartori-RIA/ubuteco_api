# frozen_string_literal: true

module Api
  module V1
    class BeersController < ApplicationController
      load_and_authorize_resource except: :index

      def index
        authorize! :read, Beer
        @pagy, @records = pagy_search_authorized(Beer)
      end

      def show; end

      def create
        @beer = Beer.new(create_params)

        if @beer.save
          render :show, status: :created
        else
          render_model_errors(@beer)
        end
      end

      def update
        if @beer.update(update_params)
          render :show, status: :ok
        else
          render_model_errors(@beer)
        end
      end

      def destroy
        if @beer.destroy
          head :no_content
        else
          render_model_errors(@beer)
        end
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
