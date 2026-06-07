# frozen_string_literal: true

module Organizations
  module Dashboard
    class Series
      COMPLETED_STATUSES = Summary::COMPLETED_STATUSES
      METRICS = %w[revenue orders].freeze
      GRAINS = %w[day].freeze

      def self.call(org:, from:, to:, grain: 'day', metric: 'revenue')
        new(org:, from:, to:, grain:, metric:).call
      end

      def initialize(org:, from:, to:, grain:, metric:)
        @org = org
        @range = RangeParser.call(org:, from:, to:)
        @grain = grain.to_s
        @metric = metric.to_s
      end

      def call
        validate_options!

        points = case @metric
                 when 'revenue' then revenue_points
                 when 'orders' then orders_points
                 else raise RangeParser::InvalidRange, I18n.t('dashboard.errors.unsupported_metric')
                 end

        {
          metric: @metric,
          grain: @grain,
          currency: @metric == 'revenue' ? @org.default_currency : nil,
          from: @range[:from_date].iso8601,
          to: @range[:to_date].iso8601,
          points: fill_missing_days(points)
        }
      end

      private

      def validate_options!
        raise RangeParser::InvalidRange, I18n.t('dashboard.errors.unsupported_grain') unless GRAINS.include?(@grain)
        raise RangeParser::InvalidRange, I18n.t('dashboard.errors.unsupported_metric') unless METRICS.include?(@metric)
      end

      def revenue_points
        bucket_values(completed_in_range.pluck(:created_at, :total_cents)) { |_date, cents| cents }
      end

      def orders_points
        bucket_values(in_range.pluck(:created_at, :id)) { |_date, _id| 1 }
      end

      def in_range
        @org.orders.where(created_at: @range[:from]..@range[:to])
      end

      def completed_in_range
        in_range.where(status: COMPLETED_STATUSES)
      end

      def bucket_values(rows)
        zone = @range[:zone]
        buckets = Hash.new(0)

        rows.each do |timestamp, value|
          day = timestamp.in_time_zone(zone).to_date
          buckets[day] += yield(day, value)
        end

        buckets
      end

      def fill_missing_days(buckets)
        (@range[:from_date]..@range[:to_date]).map do |date|
          { date: date.iso8601, value: buckets[date] || 0 }
        end
      end
    end
  end
end
