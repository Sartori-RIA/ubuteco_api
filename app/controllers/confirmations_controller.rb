# frozen_string_literal: true

class ConfirmationsController < Devise::ConfirmationsController
  respond_to :json

  # noinspection MissingYardReturnTag
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      render json: resource, include: [organization: { include: [:theme] }]
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end
end
