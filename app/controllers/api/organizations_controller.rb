# frozen_string_literal: true

module Api
  class OrganizationsController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @organizations.order(name: :asc)
    end

    def show
      render json: @organization
    end

    def create
      @organization = Organization.new(create_params)

      if @organization.save
        render json: @organization, status: :created, location: @organization
      else
        render json: @organization.errors, status: :unprocessable_entity
      end
    end

    def update
      if @organization.update(update_params)
        render json: @organization
      else
        render json: @organization.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @organization.destroy
    end

    private

    def create_params
      params.permit(:name, :cnpj, :phone, :user_id, :logo)
    end

    def update_params
      params.permit(:name, :phone, :user_id, :logo)
    end
  end
end
