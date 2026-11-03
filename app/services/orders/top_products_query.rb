# frozen_string_literal: true

module Orders
  class TopProductsQuery
    ITEM_CLASSES = Organizations::DailyBrief::Facts::ITEM_CLASSES
    MAX_LIMIT = 10

    def self.call(organization:, from:, to:, limit: 5)
      new(organization:, from:, to:, limit:).call
    end

    def initialize(organization:, from:, to:, limit:)
      @organization = organization
      @from = from
      @to = to
      @limit = limit.to_i.clamp(1, MAX_LIMIT)
    end

    def call
      range = Organizations::Dashboard::RangeParser.call(org: @organization, from: @from, to: @to)
      rows_for(range).filter_map { |type, id, quantity| row(type, id, quantity) }
    end

    private

    def rows_for(range)
      OrderItem.joins(:order)
               .where(orders: {
                        organization_id: @organization.id,
                        status: Organizations::Dashboard::Summary::COMPLETED_STATUSES,
                        created_at: range[:from]..range[:to]
                      })
               .group(:item_type, :item_id)
               .order(Arel.sql('SUM(order_items.quantity) DESC'))
               .limit(@limit)
               .pluck(:item_type, :item_id, Arel.sql('SUM(order_items.quantity)'))
    end

    def row(type, id, quantity)
      name = ITEM_CLASSES[type]&.find_by(id:, organization_id: @organization.id)&.name
      return if name.blank?

      { name:, product_type: type, id:, quantity: quantity.to_i }
    end
  end
end
