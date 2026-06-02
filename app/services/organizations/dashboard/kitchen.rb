# frozen_string_literal: true

module Organizations
  module Dashboard
    class Kitchen
      READY_STATUSES = [
        OrderItem.statuses[:ready],
        OrderItem.statuses[:with_the_client]
      ].freeze

      def self.call(org:, from:, to:)
        new(org:, from:, to:).call
      end

      def initialize(org:, from:, to:)
        @org = org
        @range = RangeParser.call(org:, from:, to:)
      end

      def call
        {
          open_dish_count: open_dish_count,
          avg_prep_seconds: avg_prep_seconds,
          from: @range[:from_date].iso8601,
          to: @range[:to_date].iso8601
        }
      end

      private

      def open_dish_count
        OrderItem.kitchen_queue_for(@org.id).kitchen_active.count
      end

      def avg_prep_seconds
        durations = dish_items_in_range.filter_map do |created_at, updated_at|
          next if updated_at.blank? || created_at.blank?

          updated_at - created_at
        end

        return 0 if durations.empty?

        (durations.sum / durations.size).to_i
      end

      def dish_items_in_range
        OrderItem
          .joins(:order)
          .where(item_type: 'Dish', status: READY_STATUSES)
          .where(orders: { organization_id: @org.id })
          .where(updated_at: @range[:from]..@range[:to])
          .pluck(:created_at, :updated_at)
      end
    end
  end
end
