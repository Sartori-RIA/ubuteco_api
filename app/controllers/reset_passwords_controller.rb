# frozen_string_literal: true

class ResetPasswordsController < ApplicationController
  include SessionRevocation

  authorize_resource class: User
  respond_to :json

  def update
    return render_i18n_api_error(:current_password_invalid) if password_change_unauthorized?

    if current_user.update(reset_params)
      revoke_other_sessions!(current_user) if params.dig(:reset_params, :password).present?
      @user = current_user
    else
      render_model_errors(current_user)
    end
  end

  protected

  def reset_params
    params.require(:reset_params).permit(:password)
  end

  def password_change_unauthorized?
    return false if params.dig(:reset_params, :password).blank?

    secret = params.dig(:reset_params, :current_password).to_s
    secret.blank? || !current_user.valid_password?(secret)
  end
end
