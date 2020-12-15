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
      @organization = Organization.new(organization_params)

      if @organization.save
        render json: @organization, status: :created, location: @organization
      else
        render json: @organization.errors, status: :unprocessable_entity
      end
    end

    def update
      if @organization.update(organization_params)
        render json: @organization
      else
        render json: @organization.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @organization.destroy
    end

    private

    def organization_params
      params.permit(:name, :cnpj, :phone, :user_id, :logo)
    end
  end
end
