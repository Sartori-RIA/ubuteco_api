# frozen_string_literal: true

module Orders
  class AddItem
    def self.call(order:, params:)
      new(order:, params:).call
    end

    def initialize(order:, params:)
      @order = order
      @params = params
    end

    def call
      item = @order.order_items.build(@params)
      item.save
      item
    end
  end
end
