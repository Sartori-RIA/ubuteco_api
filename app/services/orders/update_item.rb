# frozen_string_literal: true

module Orders
  class UpdateItem
    def self.call(order_item:, params:)
      new(order_item:, params:).call
    end

    def initialize(order_item:, params:)
      @order_item = order_item
      @params = params
    end

    def call
      previous_quantity = @order_item.quantity

      OrderItem.transaction do
        unless @order_item.update(@params)
          raise ActiveRecord::Rollback
        end

        @order_item.apply_quantity_change!(previous_quantity:)
      end

      @order_item
    rescue OrderItem::InsufficientStock
      @order_item.errors.add(:quantity, "insufficient stock")
      @order_item
    end
  end
end
