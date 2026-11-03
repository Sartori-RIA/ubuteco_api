# frozen_string_literal: true

module Ai
  class UsageRecorder
    def self.write(**attrs)
      AiUsageEvent.create!(attrs)
    end
  end
end
