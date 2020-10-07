# frozen_string_literal: true

class OrderItem < ApplicationRecord
  include KitchensHelper
  belongs_to :order
  belongs_to :item, polymorphic: true

  after_update { |order_item| order_item.message 'update' }
  after_create { |order_item| order_item.message 'create' }

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  enum status: { awaiting: 0, cooking: 1, ready: 2, with_the_client: 3, canceled: 4, empty_stock: 5 }

  def message(action)
    msg = {
      obj: format_dish_to_make(self),
      action: action,
      room: order.user.email
    }
    $redis.publish 'kitchen', msg.to_json
  end
end
