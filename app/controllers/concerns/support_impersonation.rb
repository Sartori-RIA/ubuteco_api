# frozen_string_literal: true

module SupportImpersonation
  extend ActiveSupport::Concern

  included do
    before_action :assign_impersonation
    before_action :reject_forbidden_impersonation
    after_action :audit_impersonated_mutation
  end

  private

  def assign_impersonation
    return if current_user.blank?

    payload = impersonation_payload
    return if payload.blank? || payload['impersonation'] != true

    session = open_support_session(payload)
    return revoke_impersonation(payload) if session.nil?

    Current.impersonator = User.find_by(id: payload['impersonator_id'])
    Current.support_session = session
  end

  def open_support_session(payload)
    session = SupportSession.find_by(id: payload['support_session_id'], jti: payload['jti'])
    return if session.nil? || session.ended_at.present? || session.expires_at <= Time.current
    return if session.user_id != current_user.id

    session
  end

  def revoke_impersonation(payload)
    current_user.allowlisted_jwts.where(jti: payload['jti']).delete_all
    head :unauthorized
  end

  def reject_forbidden_impersonation
    return unless Current.impersonator
    return unless forbidden_impersonation_request?

    render_i18n_api_error(:impersonation_forbidden, status: :forbidden)
  end

  def audit_impersonated_mutation
    return unless Current.support_session
    return unless request.post? || request.put? || request.patch? || request.delete?

    Current.support_session.support_session_requests.create!(
      http_method: request.request_method,
      path: request.path,
      status: response.status
    )
  end

  def forbidden_impersonation_request?
    return true if request.put? && request.path == '/auth/reset_passwords'
    return true if request.delete? && destroying_account?

    changing_account?
  end

  def destroying_account?
    request.path.match?(%r{\A/api/v1/(users|organizations|platform/organizations)/\d+\z})
  end

  def changing_account?
    return false unless request.put? || request.patch?
    return false unless request.path.match?(%r{\A/api/v1/users/\d+\z})

    params[:password].present? || params[:email].present? || params[:role_id].present?
  end

  def impersonation_payload
    token = request.authorization.to_s.split.last
    return if token.blank?

    Warden::JWTAuth::TokenDecoder.new.call(token)
  rescue StandardError
    nil
  end
end
