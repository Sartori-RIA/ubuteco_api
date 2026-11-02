# frozen_string_literal: true

module Inventory
  class RestockSuggestionsQuery
    MIN_SALE_DAYS = 7
    COVER_RANGE = (1..60)
    WINDOW_RANGE = (7..90)

    def self.call(organization:, cover_days: Inventory.restock_cover_days, window_days: Inventory.restock_window_days)
      new(organization:, cover_days:, window_days:).call
    end

    def initialize(organization:, cover_days:, window_days:)
      @organization = organization
      @cover_days = Integer(cover_days)
      @window_days = Integer(window_days)
      raise ArgumentError unless COVER_RANGE.cover?(@cover_days) && WINDOW_RANGE.cover?(@window_days)

      @zone = Time.find_zone!(organization.timezone.presence || 'UTC')
      @today = Time.current.in_time_zone(@zone).to_date
    end

    def call
      {
        cover_days: @cover_days,
        window_days: @window_days,
        items: items
      }
    end

    private

    def items
      stats = sale_stats
      Inventory::STOCKABLE_CLASSES.flat_map { |klass| items_for(klass, stats) }
                                  .sort_by { |item| [item[:days_of_cover].nil? ? 1 : 0, item[:days_of_cover] || 0, item[:name]] }
    end

    def items_for(klass, stats)
      klass.where(organization_id: @organization.id).map do |record|
        sold, sale_days = stats[[record.class.name, record.id]] || [0, 0]
        serialize(record, sold, sale_days)
      end
    end

    def serialize(record, sold, sale_days)
      avg_daily = (sold.to_f / @window_days).round(2)
      confident = sale_days >= MIN_SALE_DAYS
      days_of_cover = avg_daily.positive? ? (record.quantity_stock.to_f / avg_daily).round(1) : nil
      suggested = confident ? [0, ((avg_daily * @cover_days).ceil - record.quantity_stock.to_i)].max : nil

      {
        product_type: record.model_name.route_key,
        id: record.id,
        name: record.name,
        quantity_stock: record.quantity_stock.to_i,
        avg_daily:,
        days_of_cover:,
        suggested_quantity: suggested,
        confidence: confident ? 'ok' : 'low'
      }
    end

    # created_at is bounded so (organization_id, created_at) can be used.
    # The calendar day is converted only in the aggregate, in the org timezone.
    def sale_stats
      quoted_zone = StockMovement.connection.quote(@zone.tzinfo.name)
      sale_date = "((stock_movements.created_at AT TIME ZONE 'UTC') AT TIME ZONE #{quoted_zone})::date"

      StockMovement.where(organization_id: @organization.id)
                   .where.not(order_item_id: nil)
                   .where(delta: ...0)
                   .where(created_at: window_range)
                   .group(:product_type, :product_id)
                   .pluck(
                     :product_type,
                     :product_id,
                     Arel.sql('SUM(-delta)'),
                     Arel.sql("COUNT(DISTINCT #{sale_date})")
                   )
                   .to_h { |type, id, sold, days| [[type, id], [sold.to_i, days.to_i]] }
    end

    def window_range
      start_on = @today - (@window_days - 1)
      start_on.in_time_zone(@zone).beginning_of_day..@today.in_time_zone(@zone).end_of_day
    end
  end
end
