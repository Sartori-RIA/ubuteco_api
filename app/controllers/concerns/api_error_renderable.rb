# frozen_string_literal: true

module ApiErrorRenderable
  extend ActiveSupport::Concern

  PASSWORD_ERROR_CODES = {
    %i[password too_short] => 'password_too_short',
    %i[password too_long] => 'password_too_short',
    %i[password denied] => 'password_denied',
    %i[password pwned_password] => 'password_pwned',
    %i[reset_password_token invalid] => 'reset_token_invalid',
    %i[reset_password_token expired] => 'reset_token_invalid'
  }.freeze

  private

  def render_api_errors(errors, status: :unprocessable_content)
    payload = Array(errors).map { |error| normalize_api_error(error) }
    render json: { errors: payload }, status:
  end

  def render_model_errors(record, status: :unprocessable_content)
    errors = record.errors.map { |error| model_error_payload(error) }
    render_api_errors(errors, status:)
  end

  def render_i18n_api_error(code, status: :unprocessable_content, **options)
    render_api_errors(
      [{ code: code.to_s, message: I18n.t("api.errors.#{code}", **options) }],
      status:
    )
  end

  def model_error_payload(error)
    code = PASSWORD_ERROR_CODES[[error.attribute, error.type]]
    if code
      { code:, field: error.attribute.to_s, message: I18n.t("api.errors.#{code}") }
    else
      { code: 'validation_error', field: error.attribute.to_s, message: error.full_message }
    end
  end

  def normalize_api_error(error)
    case error
    when Hash
      {
        code: error[:code] || "error",
        field: error[:field],
        message: error[:message] || error[:code].to_s,
      }.compact
    when ActiveModel::Error
      {
        code: "validation_error",
        field: error.attribute.to_s,
        message: error.full_message,
      }
    else
      { code: "error", message: error.to_s }
    end
  end
end
