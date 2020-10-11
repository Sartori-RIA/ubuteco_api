# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    build_resource(sign_up_params)

    resource.save
    if resource.errors.empty?
      sign_in(resource)
      render json: resource, include: [:theme]
    else
      validation_error(resource)
    end
  end

  protected

  def sign_up_params
    params.permit(:name,
                  :password,
                  :email,
                  :company_name,
                  :cnpj)
  end
end
