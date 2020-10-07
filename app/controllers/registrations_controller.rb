# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    build_resource(sign_up_params)

    resource.save
    render_resource(resource)
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
