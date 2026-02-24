# frozen_string_literal: true

module Api
  module V1
    class WinesController < ApplicationController
      load_and_authorize_resource

      def index
        search = Wine.pagy_search(params[:q].presence || "*", page: params[:page])
        @pagy, @records = pagy(:searchkick, search)
      end

      def show; end

      def create
        @wine = Wine.new(create_params)
        if @wine.save
          render :show, status: :created
        else
          render json: @wine.errors.full_messages, status: :unprocessable_content
        end
      end

      def update
        if @wine.update(update_params)
          render :show
        else
          render json: @wine.errors.full_messages, status: :unprocessable_content
        end
      end

      def destroy
        if @wine.destroy
          head :no_content
        else
          render json: @wine.errors.full_messages, status: :unprocessable_content
        end
      end

      private

      def create_params
        update_params.merge(organization_id: current_user.organization_id)
      end

      def update_params
        params.permit(:name, :quantity_stock, :image, :abv, :price, :description, :maker, :maker_id,
                      :vintage_wine, :visual, :user_id, :ripening, :grapes, :wine_style, :wine_style_id)
      end
    end
  end
end
