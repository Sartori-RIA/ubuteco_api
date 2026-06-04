# frozen_string_literal: true

module CorsOrigins
  DEFAULT_DEV_ORIGINS = %w[
    http://localhost:3000
    http://localhost:3001
    http://localhost:4000
    http://127.0.0.1:3000
    http://127.0.0.1:3001
    http://127.0.0.1:4000
  ].freeze

  module_function

  def allowed
    if Rails.env.development? || Rails.env.test?
      (DEFAULT_DEV_ORIGINS + env_origins).uniq
    else
      env_origins.presence || raise_missing_origins!
    end
  end

  def env_origins
    ENV.fetch("CORS_ORIGINS", "")
       .split(",")
       .map(&:strip)
       .reject(&:blank?)
  end

  def raise_missing_origins!
    raise "CORS_ORIGINS must be set in #{Rails.env} (comma-separated URLs)"
  end
end
