# frozen_string_literal: true

class OrderItem < ApplicationRecord
  include KitchensHelper

  after_update { |order_item| order_item.message 'update' }
  after_create { |order_item| order_item.message 'create' }

  after_create :recalculate_total
  after_update :recalculate_total
  after_destroy :recalculate_total

  after_create :set_default_status
  after_update :set_default_status

  after_destroy :reset_stock

  belongs_to :order
  belongs_to :item, polymorphic: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  enum status: { awaiting: 0, cooking: 1, ready: 2, with_the_client: 3, canceled: 4, empty_stock: 5 }

  def update_stock(diff:, is_quantity_lower:)
    return if item_type == 'Dish'
    mew_quantity = if is_quantity_lower
                     self.item.quantity_stock + diff
                   else
                     self.item.quantity_stock - diff
                   end
    self.item.update(quantity_stock: mew_quantity)
  end

  protected

  def set_default_status
    return if item_type == 'Dish'
    self.status = 3
  end

  def message(action)
    msg = {
      obj: format_dish_to_make(self),
      action: action
    }
    ActionCable.server.broadcast("kitchens_#{order.organization.cnpj}", msg.to_json)
  end

  def recalculate_total
    order.recalculate_total!
  end

  def reset_stock
    return if item_type == 'Dish'
    item.update(quantity_stock: item.quantity_stock + quantity)
  end
end
