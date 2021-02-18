# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  before_action :user_attributes, only: :create

  def create
    build_resource @attributes
    resource.save
    if resource.errors.empty?
      if params[:organization_attributes].nil?
        sign_in resource
        render json: resource, include: :role
      else
        create_with_organization
      end
    else
      validation_error resource
    end
  end

  protected

  def sign_up_params
    params.require(:user).permit(:name, :password, :email, :avatar)
  end

  def organization_params
    params.require(:organization_attributes).permit(:cnpj, :logo, :name, :phone)
  end

  def user_attributes
    if sign_up_params.present?
      @attributes = sign_up_params
      @attributes[:role] = params[:organization_attributes].present? ? Role.find_by!(name: 'ADMIN') : Role.find_by!(name: 'CUSTOMER')
    else
      render status: :unprocessable_entity
    end
  end

  def build_organization(user)
    attributes = organization_params
    attributes[:user_id] = user.id
    @organization = Organization.new(attributes)
    if @organization.save
      user.update(organization_id: @organization.id)
      true
    else
      user.really_destroy!
      false
    end
  end

  def create_with_organization
    if build_organization resource
      sign_in resource
      render json: resource, include: [:role, { organization: { include: [:theme] } }]
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end
end
