# frozen_string_literal: true

module OrdersHelper
  def already_exists_in_order?(attributes)
    OrderItem.exists?(item_id: attributes[:item_id],
                      order_id: attributes[:order_id],
                      item_type: attributes[:item_type])
  end
end
