# frozen_string_literal: true

module Ai
  # Rejects model text that contains a number the caller did not supply.
  class NumberGuard
    def self.allowed?(text, numbers)
      allowed = numbers.flat_map { |value| forms(value) }.to_set
      extracted(text).all? { |token| allowed.include?(token) }
    end

    def self.extracted(text)
      text.to_s.scan(/\d+(?:[.,]\d+)?/).map { |token| canonical(token) }
    end

    def self.forms(value)
      return [] if value.nil?

      number = Float(value)
      [canonical(number), format('%.1f', number), format('%.2f', number)].uniq
    rescue ArgumentError, TypeError
      []
    end

    def self.canonical(value)
      number = value.is_a?(Numeric) ? value.to_f : value.to_s.tr(',', '.').to_f
      return number.to_i.to_s if (number % 1).zero?

      format('%.4f', number).sub(/0+\z/, '')
    end
  end
end
