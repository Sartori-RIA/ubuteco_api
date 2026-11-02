# frozen_string_literal: true

module Ai
  class ContentLog
    def self.write(feature:, system:, messages:, text:)
      return unless enabled?

      Rails.logger.info("[ai:#{feature}] system=#{system.inspect} messages=#{messages.inspect} text=#{text.inspect}")
    end

    def self.enabled?
      return false if Rails.env.production?

      ActiveModel::Type::Boolean.new.cast(ENV.fetch('AI_LOG_CONTENT', 'false'))
    end
  end
end
