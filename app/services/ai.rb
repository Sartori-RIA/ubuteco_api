# frozen_string_literal: true

module Ai
  class Error < StandardError; end
  class DisabledError < Error; end
  class RateLimitedError < Error; end
  class ProviderError < Error; end

  # Reserved for features that require structured output (plan 21).
  class InvalidOutputError < Error; end

  def self.enabled_for?(organization)
    return false if organization.blank?

    globally_enabled? && organization.ai_enabled?
  end

  def self.globally_enabled?
    ActiveModel::Type::Boolean.new.cast(ENV.fetch('AI_ENABLED', 'false'))
  end

  def self.result(text: '', tool_calls: [], input_tokens: 0, output_tokens: 0, stop_reason: 'end_turn')
    Result.new(
      text:,
      tool_calls:,
      usage: Usage.new(input_tokens:, output_tokens:),
      stop_reason:
    )
  end
end
