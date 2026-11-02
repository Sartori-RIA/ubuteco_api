# frozen_string_literal: true

module Ai
  class Config
    Tier = Data.define(:model, :max_tokens, :timeout_seconds)

    def self.tier(name)
      raw = tiers.fetch(name.to_sym)
      Tier.new(
        model: model_override(name) || raw.fetch(:model),
        max_tokens: Integer(raw.fetch(:max_tokens)),
        timeout_seconds: Integer(raw.fetch(:timeout_seconds))
      )
    rescue KeyError
      raise ArgumentError, "unknown AI tier: #{name}"
    end

    def self.tiers
      Rails.application.config_for(:ai).fetch(:tiers)
    end

    def self.model_override(name)
      key = name.to_sym == :fast ? 'AI_MODEL_FAST' : 'AI_MODEL_SMART'
      return if %i[fast smart].exclude?(name.to_sym)

      ENV[key].presence
    end
    private_class_method :model_override, :tiers
  end
end
