# frozen_string_literal: true

module Inventory
  module Intake
    module JsonOutput
      def parse_json(text)
        cleaned = text.to_s.strip.sub(/\A```(?:json)?\s*/i, '').sub(/\s*```\z/, '')
        JSON.parse(cleaned)
      rescue JSON::ParserError
        raise Ai::InvalidOutputError
      end
    end
  end
end
