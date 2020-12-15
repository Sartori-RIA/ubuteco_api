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
      render json: @makers.order(name: :asc)
    end

    def create
      @maker = Maker.new(maker_params)

      if @maker.save
        render json: @maker, status: :created
      else
        render json: @maker.errors, status: :unprocessable_entity
      end
    end

    def update
      if @maker.update(maker_params)
        render json: @maker
      else
        render json: @maker.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @maker.destroy
    end

    private

    def maker_params
      params.permit(:name, :country).merge(organization_id: current_user.organization_id)
    end
  end
end
