# frozen_string_literal: true

module Organizations
  module Dashboard
    class Summary
      COMPLETED_STATUSES = [Order.statuses[:closed], Order.statuses[:payed]].freeze

      def self.call(org:, from:, to:)
        new(org:, from:, to:).call
      end

      def initialize(org:, from:, to:)
        @org = org
        @range = RangeParser.call(org:, from:, to:)
      end

      def call
        in_range = @org.orders.where(created_at: @range[:from]..@range[:to])
        completed = in_range.where(status: COMPLETED_STATUSES)
        revenue_cents = completed.sum(:total_cents)
        completed_count = completed.count

        {
          revenue_cents: revenue_cents,
          orders_count: in_range.count,
          open_orders_count: @org.orders.open.count,
          average_ticket_cents: completed_count.positive? ? (revenue_cents / completed_count) : 0,
          currency: @org.default_currency,
          items_by_type: items_by_type,
          from: @range[:from_date].iso8601,
          to: @range[:to_date].iso8601
        }
      end

      private

      def items_by_type
        OrderItem
          .joins(:order)
          .where(orders: {
                   organization_id: @org.id,
                   created_at: @range[:from]..@range[:to],
                   status: COMPLETED_STATUSES
                 })
          .group(:item_type)
          .sum(:quantity)
          .transform_keys(&:to_s)
      end
    end
  end
end
