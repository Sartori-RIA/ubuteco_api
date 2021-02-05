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

    def search
      @organization = Organization.search params[:q]
      render json: @organization.order(name: :asc)
    end

    def update
      if @organization.update(update_params)
        render json: @organization
      else
        render json: @organization.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @organization.user.destroy
      @organization.destroy
    end

    def cnpj_available?
      param = CNPJ.new(params[:q])
      organization = Organization.find_by(cnpj: param.formatted)
      if organization.nil?
        render json: {}, status: :no_content
      else
        render json: {}, status: :ok
      end
    end

    private

    def update_params
      params.permit(:name, :phone, :user_id, :logo)
    end
  end
end
