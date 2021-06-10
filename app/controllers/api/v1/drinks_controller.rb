# frozen_string_literal: true

module Api
  class V1::DrinksController < ApplicationController
    load_and_authorize_resource

    def index
      @drinks = paginate @drinks.order(name: :asc), include: %i[maker]
    end

    def show; end

    def search
      @drinks = Drink.search params[:q]
      @drinks = paginate @drinks.order(name: :asc), include: %i[maker]
    end

    def create
      @drink = Drink.new(create_params)

      if @drink.save
        render status: :created
      else
        render json: @drink.errors, status: :unprocessable_entity
      end
    end

    def update
      render json: @drink.errors, status: :unprocessable_entity unless @drink.update(update_params)
    end

    def destroy
      @drink.destroy
    end

    private

    def create_params
      update_params.merge(organization_id: current_user.organization_id)
    end

    def update_params
      params.permit(
        :name,
        :description,
        :image,
        :maker_id,
        :maker,
        :price,
        :quantity_stock,
        :flavor
      )
    end
  end
end
