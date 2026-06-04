# frozen_string_literal: true

module ApiErrorRenderable
  extend ActiveSupport::Concern

  private

  def render_api_errors(errors, status: :unprocessable_content)
    payload = Array(errors).map { |error| normalize_api_error(error) }
    render json: { errors: payload }, status:
  end

  def render_model_errors(record, status: :unprocessable_content)
    errors = record.errors.map do |error|
      {
        code: "validation_error",
        field: error.attribute.to_s,
        message: error.full_message,
      }
    end
    render_api_errors(errors, status:)
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
