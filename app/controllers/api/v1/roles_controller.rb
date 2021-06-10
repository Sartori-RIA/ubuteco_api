# frozen_string_literal: true

module Api
  class V1::RolesController < ApplicationController
    load_and_authorize_resource

    def index; end

    def show; end

    def create
      @role = Role.new(create_params)

      if @role.save
        render status: :created
      else
        render json: @role.errors, status: :unprocessable_entity
      end
    end

    def update
      render json: @role.errors, status: :unprocessable_entity unless @role.update(update_params)
    end

    def destroy
      @role.destroy
    end

    protected

    def create_params
      params.permit(:name)
    end

    def update_params
      params.permit(:id, :name)
    end
  end
end
