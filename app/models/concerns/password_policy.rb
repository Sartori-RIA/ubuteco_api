# frozen_string_literal: true

module PasswordPolicy
  extend ActiveSupport::Concern

  included do
    validate :password_not_denied, if: -> { password.present? }
  end

  def issue_password_reset_token!
    raw, encoded = Devise.token_generator.generate(self.class, :reset_password_token)
    update!(reset_password_token: encoded, reset_password_sent_at: Time.now.utc)
    raw
  end

  def revoke_other_sessions!(except_jti: nil)
    tokens = allowlisted_jwts
    tokens = tokens.where.not(jti: except_jti) if except_jti.present?
    tokens.delete_all
  end

  # The gem swallows Pwned::Error without a log. Keep that fail-open behavior and record the failure.
  def password_pwned?(password)
    options = {
      headers: { 'User-Agent' => 'devise_pwned_password' },
      read_timeout: self.class.pwned_password_read_timeout,
      open_timeout: self.class.pwned_password_open_timeout
    }
    @pwned_count = Pwned::Password.new(password.to_s, options).pwned_count
    @pwned_count >= self.class.min_password_matches
  rescue Pwned::Error => e
    Rails.logger.warn("Pwned Passwords check failed: #{e.class}")
    false
  end

  private

  def password_not_denied
    candidate = password.to_s.downcase
    denied = [email.to_s.split('@').first, organization&.name]
    return unless denied.any? { |value| value.to_s.strip.downcase == candidate && value.present? }

    errors.add(:password, :denied)
  end
end
