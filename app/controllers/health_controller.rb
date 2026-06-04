# frozen_string_literal: true

class HealthController < ActionController::API
  def show
    checks = {
      status: "ok",
      redis: redis_status,
    }

    status = checks[:redis] == "error" ? :service_unavailable : :ok
    render json: checks, status:
  end

  private

  def redis_status
    url = ENV["REDIS_URL"]
    return "skipped" if url.blank?

    Redis.new(url:).ping == "PONG" ? "ok" : "error"
  rescue StandardError
    "error"
  end
end
