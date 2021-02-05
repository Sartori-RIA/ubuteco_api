# frozen_string_literal: true

module Api
  class MakersController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @makers.order(name: :asc)
    end

    def show
      render json: @maker
    end

    def search
      @makers = Maker.search params[:q]
      paginate json: @makers.order(name: :asc)
    end

    def create
      @maker = Maker.new(create_params)

      if @maker.save
        render json: @maker, status: :created
      else
        render json: @maker.errors, status: :unprocessable_entity
      end
    end

    def update
      if @maker.update(update_params)
        render json: @maker
      else
        render json: @maker.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @maker.destroy
    end

    private

    def create_params
      update_params.merge(organization_id: current_user.organization_id)
    end

    def update_params
      params.permit(:name, :country)
    end
  end
end
