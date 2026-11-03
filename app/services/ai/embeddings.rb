# frozen_string_literal: true

module Ai
  # Voyage AI is the production embedder (ADR 008). Tests use Ai::Embeddings::Fake.
  class Embeddings
    DIMENSIONS = 512
    MODEL = ENV.fetch('EMBEDDING_MODEL', 'voyage-3-lite')

    def self.embed(texts, organization:, user: nil)
      new(texts:, organization:, user:).embed
    end

    def self.provider
      return Fake if Rails.env.test? || ENV['AI_CLIENT'] == 'fake'
      return Voyage if ENV['VOYAGE_API_KEY'].present?

      raise ProviderError, 'VOYAGE_API_KEY is missing'
    end

    def initialize(texts:, organization:, user:)
      @texts = Array(texts).map(&:to_s)
      @organization = organization
      @user = user
    end

    def embed
      raise ArgumentError, 'organization is required' if organization.nil?
      raise ArgumentError, 'texts are required' if texts.empty?

      started = monotonic_now
      ensure_enabled!(started)
      ensure_within_limit!(started)
      vectors = self.class.provider.embed(texts)
      record(status: 'ok', started:)
      vectors
    rescue ProviderError
      record(status: 'error', started:)
      raise
    end

    private

    attr_reader :texts, :organization, :user

    def ensure_enabled!(started)
      return if Ai.enabled_for?(organization)

      record(status: 'disabled', started:)
      raise DisabledError
    end

    def ensure_within_limit!(started)
      return if RateLimiter.new.allow?(organization:, feature: Feature::MENU_SEARCH)

      record(status: 'rate_limited', started:)
      raise RateLimitedError
    end

    def record(status:, started:)
      UsageRecorder.write(
        organization:,
        user:,
        feature: Feature::MENU_SEARCH,
        model: status == 'ok' ? self.class::MODEL : nil,
        input_tokens: 0,
        output_tokens: 0,
        latency_ms: ((monotonic_now - started) * 1000).round,
        status:
      )
    end

    def monotonic_now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
