# frozen_string_literal: true

module Orders
  class RemoveItem
    def self.call(order_item:)
      order_item.destroy
      order_item.destroyed?
    end
  end
end
