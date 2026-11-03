# frozen_string_literal: true

module Organizations
  module DailyBrief
    class Facts
      COMPLETED = [Order.statuses[:closed], Order.statuses[:payed]].freeze
      ITEM_CLASSES = {
        'Dish' => Dish,
        'Beer' => Beer,
        'Wine' => Wine,
        'Drink' => Drink,
        'Food' => Food
      }.freeze

      def self.call(organization:, now: Time.current)
        new(organization:, now:).call
      end

      def initialize(organization:, now:)
        @organization = organization
        @zone = Time.find_zone!(organization.timezone.presence || 'UTC')
        @now = now.in_time_zone(@zone)
        @today = @now.to_date
        @yesterday = @today - 1
      end

      def call
        revenue_facts.merge(activity_facts)
      end

      private

      def revenue_facts
        yesterday = period(yesterday_range)
        today = period(today_range)
        last_week_cents = revenue_cents(last_week_range)

        {
          locale: @organization.locale.presence || 'pt-BR',
          currency: @organization.default_currency,
          yesterday: @yesterday.iso8601,
          today: @today.iso8601,
          yesterday_revenue: money(yesterday[:cents]),
          last_week_revenue: money(last_week_cents),
          revenue_delta_percent: delta_percent(yesterday[:cents], last_week_cents),
          yesterday_orders: yesterday[:count],
          yesterday_average_ticket: money(average_ticket(yesterday)),
          today_revenue: money(today[:cents]),
          today_orders: today[:count]
        }
      end

      def activity_facts
        {
          top_products: top_products,
          low_stock_count: low_stock.size,
          low_stock_names: names_of(low_stock),
          expiring_count: expiring.size,
          expiring_names: names_of(expiring),
          avg_prep_minutes: (kitchen[:avg_prep_seconds].to_i / 60.0).round
        }
      end

      def names_of(items)
        items.first(5).pluck(:name)
      end

      def period(range)
        orders = completed_orders(range)
        { cents: orders.sum(:total_cents), count: orders.count }
      end

      def average_ticket(stats)
        return 0 unless stats[:count].positive?

        stats[:cents] / stats[:count]
      end

      def money(cents)
        Money.new(cents.to_i, @organization.default_currency).format
      end

      def delta_percent(current, previous)
        return nil if previous.to_i.zero?

        (((current - previous).to_f / previous) * 100).round
      end

      def revenue_cents(range)
        completed_orders(range).sum(:total_cents)
      end

      def completed_orders(range)
        @organization.orders.where(status: COMPLETED, created_at: range)
      end

      def yesterday_range
        day_range(@yesterday)
      end

      def last_week_range
        day_range(@yesterday - 7)
      end

      def today_range
        @today.in_time_zone(@zone).beginning_of_day..@now
      end

      def day_range(date)
        date.in_time_zone(@zone).all_day
      end

      def top_products
        OrderItem.joins(:order)
                 .where(orders: { organization_id: @organization.id, status: COMPLETED, created_at: yesterday_range })
                 .group(:item_type, :item_id)
                 .order(Arel.sql('SUM(order_items.quantity) DESC'))
                 .limit(3)
                 .pluck(:item_type, :item_id, Arel.sql('SUM(order_items.quantity)'))
                 .filter_map do |type, id, quantity|
                   name = ITEM_CLASSES[type]&.find_by(id:)&.name
                   next if name.blank?

                   { name:, quantity: quantity.to_i }
                 end
      end

      def low_stock
        @low_stock ||= Inventory::LowStockQuery.call(organization_id: @organization.id)
      end

      def expiring
        @expiring ||= Inventory::ExpiringProductsQuery.call(organization: @organization)
      end

      def kitchen
        @kitchen ||= Organizations::Dashboard::Kitchen.call(
          org: @organization,
          from: @yesterday.iso8601,
          to: @yesterday.iso8601
        )
      end
    end
  end
end
