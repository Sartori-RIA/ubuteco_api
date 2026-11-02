# frozen_string_literal: true

module Ai
  class RateLimiter
    def self.redis
      @redis ||= Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
    end

    def allow?(organization:, feature:)
      now = Time.current.in_time_zone(zone_for(organization))
      minute = incr(minute_key(organization, feature, now), 120)
      day = incr(day_key(organization, feature, now), 172_800)
      minute <= minute_limit && day <= day_limit
    end

    def minute_limit
      Integer(ENV.fetch('AI_RATE_LIMIT_PER_MINUTE', '30'))
    end

    def day_limit
      Integer(ENV.fetch('AI_RATE_LIMIT_PER_DAY', '200'))
    end

    private

    def zone_for(organization)
      Time.find_zone(organization.timezone) || Time.zone
    end

    def minute_key(organization, feature, now)
      "ai:rl:#{organization.id}:#{feature}:m:#{now.strftime('%Y%m%d%H%M')}"
    end

    def day_key(organization, feature, now)
      "ai:rl:#{organization.id}:#{feature}:d:#{now.strftime('%Y%m%d')}"
    end

    def incr(key, ttl)
      count = self.class.redis.incr(key)
      self.class.redis.expire(key, ttl) if count == 1
      count
    end
  end
end
