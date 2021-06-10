# frozen_string_literal: true

class ConfirmationsController < Devise::ConfirmationsController
  respond_to :json

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?
    return if resource.errors.blank?

    respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
  end
end
