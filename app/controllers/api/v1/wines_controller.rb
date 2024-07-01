# frozen_string_literal: true

module Api
  module V1
    class WinesController < ApplicationController
      load_and_authorize_resource

      def index
        pagy_render @wines.order(name: :asc), %i[wine_style maker]
      end

      def show; end

      def search
        @wines = Wine.search params[:q]
        pagy_render @wines.order(name: :asc),  %i[wine_style maker]
      end

      def create
        @wine = Wine.new(create_params)
        if @wine.save
          render status: :created
        else
          render json: @wine.errors, status: :unprocessable_entity
        end
      end

      def update
        render json: @wine.errors, status: :unprocessable_entity unless @wine.update(update_params)
      end

      def destroy
        @wine.destroy
      end

      private

      def create_params
        update_params.merge(organization_id: current_user.organization_id)
      end

      def update_params
        params.permit(:name, :quantity_stock, :image, :abv, :price, :description, :maker, :maker_id,
                      :vintage_wine, :visual, :user_id, :id, :ripening, :grapes, :wine_style, :wine_style_id)
      end
    end
  end
end
