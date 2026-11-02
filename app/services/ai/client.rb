# frozen_string_literal: true

module Ai
  class Client
    def self.complete(...)
      new(...).complete
    end

    def self.default_provider
      return FakeClient if Rails.env.test? || ENV['AI_CLIENT'] == 'fake'

      AnthropicClient
    end

    def initialize(**args)
      @feature = args.fetch(:feature)
      @tier = args.fetch(:tier)
      @system = args.fetch(:system)
      @messages = args.fetch(:messages)
      @organization = args.fetch(:organization)
      @tools = args[:tools]
      @user = args[:user]
      @provider = args[:provider] || self.class.default_provider
    end

    def complete
      validate!
      started = monotonic_now
      result = call(started)
      ContentLog.write(feature: feature_name, system:, messages:, text: result.text)
      result
    end

    private

    attr_reader :feature, :tier, :system, :messages, :tools, :organization, :user, :provider

    def call(started)
      ensure_enabled!(started)
      ensure_within_limit!(started)
      call_provider(started)
    rescue ProviderError
      record(status: 'error', started:)
      raise
    end

    def ensure_enabled!(started)
      return if Ai.enabled_for?(organization)

      record(status: 'disabled', started:)
      raise DisabledError
    end

    def ensure_within_limit!(started)
      return if rate_limiter.allow?(organization:, feature: feature_name)

      record(status: 'rate_limited', started:)
      raise RateLimitedError
    end

    def call_provider(started)
      result = provider.complete(tier:, system:, messages:, tools:)
      record(status: 'ok', started:, result:)
      result
    end

    def validate!
      raise ArgumentError, 'organization is required' if organization.nil?
      raise ArgumentError, "unknown AI feature: #{feature}" unless Feature::ALL.include?(feature.to_s)

      Config.tier(tier)
    end

    def record(status:, started:, result: nil)
      UsageRecorder.write(
        organization:,
        user:,
        feature: feature_name,
        model: model_for(status),
        input_tokens: result&.usage&.input_tokens || 0,
        output_tokens: result&.usage&.output_tokens || 0,
        latency_ms: elapsed_ms(started),
        status:
      )
    end

    def model_for(status)
      return if %w[disabled rate_limited].include?(status)

      Config.tier(tier).model
    end

    def feature_name
      feature.to_s
    end

    def rate_limiter
      @rate_limiter ||= RateLimiter.new
    end

    def monotonic_now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def elapsed_ms(started)
      ((monotonic_now - started) * 1000).round
    end
  end
end
