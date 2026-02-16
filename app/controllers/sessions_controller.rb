# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  wrap_parameters :user
  respond_to :json

  protected

  def respond_with(resource, _opts = {})
    @user = resource
  end

  def respond_to_on_destroy(_resource)
    head :no_content
  end

  def sign_in_params
    params.permit(:email, :password)
  end
end
