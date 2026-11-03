# frozen_string_literal: true

class PasswordsController < Devise::PasswordsController
  respond_to :json

  def create
    user = User.find_by(email: params.require(:email))
    deliver_reset_link(user) if user
    head :ok
  end

  def update
    user = User.reset_password_by_token(reset_attributes)
    if user.errors.empty?
      user.revoke_other_sessions!
      head :ok
    else
      render_model_errors(user)
    end
  end

  private

  def deliver_reset_link(user)
    token = user.issue_password_reset_token!
    UserMailer.with(user:, reset_token: token).password_reset.deliver_now!
  end

  def reset_attributes
    attrs = params.permit(:reset_password_token, :password, :password_confirmation).to_h.symbolize_keys
    attrs[:password_confirmation] = attrs[:password] if attrs[:password_confirmation].blank?
    attrs
  end
end
