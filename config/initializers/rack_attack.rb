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

  if Rails.env.development?
    Rack::Attack.safelist("allow from localhost") do |req|
      req.ip == "127.0.0.1" || req.ip == "::1"
    end
  end
end
