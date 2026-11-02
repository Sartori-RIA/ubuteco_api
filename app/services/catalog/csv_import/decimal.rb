# frozen_string_literal: true

module Catalog
  module CsvImport
    class Decimal
      class InvalidNumber < StandardError; end

      def self.parse(raw)
        text = raw.to_s.strip
        raise InvalidNumber if text.blank?
        raise InvalidNumber if thousands?(text)

        BigDecimal(text.tr(',', '.'))
      rescue ArgumentError, InvalidNumber
        raise InvalidNumber
      end

      def self.thousands?(text)
        return true if text.count('.') > 1 || text.count(',') > 1
        return true if text.include?('.') && text.include?(',')

        false
      end
    end
  end
end
