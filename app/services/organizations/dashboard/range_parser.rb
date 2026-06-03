# frozen_string_literal: true

module Organizations
  module Dashboard
    class RangeParser
      MAX_SPAN_DAYS = 90
      InvalidRange = Class.new(StandardError)

      def self.call(org:, from:, to:)
        new(org:, from:, to:).parse
      end

      def initialize(org:, from:, to:)
        @org = org
        @from = from
        @to = to
      end

      def parse
        zone = Time.find_zone!(@org.timezone.presence || 'UTC')
        from_date = Date.iso8601(@from.to_s)
        to_date = Date.iso8601(@to.to_s)

        raise InvalidRange, 'from must be on or before to' if from_date > to_date
        raise InvalidRange, "range exceeds #{MAX_SPAN_DAYS} days" if (to_date - from_date).to_i > MAX_SPAN_DAYS

        {
          from: zone.local(from_date.year, from_date.month, from_date.day).beginning_of_day,
          to: zone.local(to_date.year, to_date.month, to_date.day).end_of_day,
          from_date: from_date,
          to_date: to_date,
          zone: zone
        }
      end
    end
  end
end
