# frozen_string_literal: true

module SessionRevocation
  extend ActiveSupport::Concern

  private

  def revoke_other_sessions!(user)
    except_jti = user.id == current_user&.id ? current_jti : nil
    user.revoke_other_sessions!(except_jti:)
  end

  def current_jti
    token = request.authorization.to_s.split.last
    return if token.blank?

    Warden::JWTAuth::TokenDecoder.new.call(token)['jti']
  rescue StandardError
    nil
  end
end
