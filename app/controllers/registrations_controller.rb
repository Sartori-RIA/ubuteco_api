# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    @user = User.new sign_up_params
    @user.save
    if @user.errors.empty?
      create_account
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  protected

  def sign_up_params
    role = params[:organization_attributes].present? ? Role.find_by!(name: 'ADMIN') : Role.find_by!(name: 'CUSTOMER')
    params.require(:user).permit(:name, :password, :email, :avatar, :role).merge(role: role)
  end

  def organization_params
    params.require(:organization_attributes).permit(:cnpj, :logo, :name, :phone, :user_id).merge(user_id: @user.id)
  end

  private

  def build_organization
    @organization = Organization.new(organization_params)
    @organization.save
  end

  def create_with_organization
    if build_organization
      @user.update(organization_id: @organization.id)
      sign_in @user
    else
      @user.really_destroy!
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  def create_account
    if params[:organization_attributes].blank?
      sign_in @user
    else
      create_with_organization
    end
  end
end
