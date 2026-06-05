require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Active Storage: S3-compatible when AWS_BUCKET is set (Railway / T3); otherwise local disk.
  config.active_storage.service = ENV["AWS_BUCKET"].present? ? :amazon : :local

  # Railway / reverse-proxy TLS termination.
  config.assume_ssl = true
  config.force_ssl = true
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  config.active_job.queue_adapter = :sidekiq

  if ENV["MAILER_ADDRESS"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.smtp_settings = {
      address: ENV.fetch("MAILER_ADDRESS"),
      port: ENV.fetch("MAILER_PORT", 587).to_i,
      user_name: ENV.fetch("MAILER_SMTP_USER", ENV.fetch("MAILER_USER_NAME", "resend")),
      password: ENV.fetch("MAILER_PASSWORD"),
      authentication: :plain,
      enable_starttls_auto: true
    }
    mailer_host = ENV["MAILER_HOST"].presence || ENV["RAILWAY_PUBLIC_DOMAIN"].presence || "example.com"
    config.action_mailer.default_url_options = { host: mailer_host, protocol: "https" }
  end

  config.i18n.fallbacks = true

  config.active_record.dump_schema_after_migration = false

  config.active_record.attributes_for_inspect = [ :id ]

  config.hosts << ENV["RAILWAY_PUBLIC_DOMAIN"] if ENV["RAILWAY_PUBLIC_DOMAIN"].present?
  if ENV["ALLOWED_HOSTS"].present?
    ENV["ALLOWED_HOSTS"].split(",").map(&:strip).reject(&:blank?).each { config.hosts << _1 }
  end
  config.hosts << /.*\.railway\.app/ if ENV["RAILWAY_ENVIRONMENT_NAME"].present? || ENV["RAILWAY_PUBLIC_DOMAIN"].present?

  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
