# frozen_string_literal: true

module Organizations
  module Dashboard
    module Cache
      TTL = 3.minutes

      def self.fetch(org:, kind:, **params, &block)
        Rails.cache.fetch(cache_key(org, kind, params), expires_in: TTL, &block)
      end

      def self.cache_key(org, kind, params)
        parts = params.values.map(&:to_s).join(':')
        "dashboard:org:#{org.id}:#{kind}:#{parts}"
      end
    end
  end
end
