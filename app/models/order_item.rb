# frozen_string_literal: true

class OrderItem < ApplicationRecord
  include KitchensHelper
  belongs_to :order
  belongs_to :item, polymorphic: true

  after_update { |order_item| order_item.message 'update' }
  after_create { |order_item| order_item.message 'create' }

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  enum status: { awaiting: 0, cooking: 1, ready: 2, with_the_client: 3, canceled: 4, empty_stock: 5 }

  def already_in_order(attributes)
    exists?(item_id: attributes[:item_id],
            order_id: attributes[:order_id],
            item_type: attributes[:item_type])
  end

  def message(action)
    msg = {
      obj: format_dish_to_make(self),
      action: action
    }
    ActionCable.server.broadcast("kitchens_#{order.organization.cnpj}", msg.to_json)
  end
end
