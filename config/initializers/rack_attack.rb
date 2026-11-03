class Rack::Attack

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blocklisting and
  # safelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###

  # Throttle all requests by IP (60rpm)
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  ### Prevent Brute-Force Login Attacks ###

  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/auth/sign_in" && req.post?
  end

  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/auth/sign_in" && req.post?
      req.params["email"].presence
    end
  end

  throttle("signups/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/auth/sign_up" && req.post?
  end

  throttle("password_resets/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/auth/password" && (req.post? || req.put?)
  end

  throttle("impersonations/actor", limit: 10, period: 1.hour) do |req|
    if req.post? && req.path == "/api/v1/platform/impersonations"
      Rack::Attack.impersonation_actor_id(req) || req.ip
    end
  end

  ### Search abuse (OpenSearch-backed index endpoints) ###

  throttle("search/ip", limit: 60, period: 1.minute) do |req|
    if req.get? && req.path.start_with?("/api/v1/") && req.params["q"].present?
      req.ip
    end
  end

  ### Custom Throttle Response ###

  self.throttled_response_retry_after_header = true

  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]
    period = match_data[:period]
    retry_after = period - (Time.now.to_i % period)

    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s,
      },
      [{ errors: [{ code: "rate_limit_exceeded", message: "Retry later" }] }.to_json],
    ]
  end

  def self.impersonation_actor_id(req)
    token = req.get_header("HTTP_AUTHORIZATION").to_s.split.last
    return if token.blank?

    segment = token.split(".")[1].to_s
    segment += "=" * ((4 - (segment.length % 4)) % 4)
    JSON.parse(Base64.urlsafe_decode64(segment))["sub"]
  rescue StandardError
    nil
  end

  if Rails.env.development?
    Rack::Attack.safelist("allow from localhost") do |req|
      req.ip == "127.0.0.1" || req.ip == "::1"
    end
  end

  # Disabled in test by default; rack_attack_spec enables explicitly.
  Rack::Attack.enabled = false if Rails.env.test?
end
