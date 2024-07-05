# frozen_string_literal: true

class OrderItem < ApplicationRecord
  searchkick callbacks: :async

  after_create :recalculate_total
  after_create :set_default_status, if: :dish?
  after_create :decrement_stock, unless: :dish?
  after_create { |order_item| order_item.message 'create' }

  after_update :recalculate_total
  after_update :set_default_status, if: :dish?
  after_update { |order_item| order_item.message 'update' }

  after_destroy :recalculate_total
  after_destroy :reset_stock, unless: :dish?

  after_commit :enqueue_reindex_job

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  belongs_to :order
  belongs_to :item, polymorphic: true

  enum status: { awaiting: 0, cooking: 1, ready: 2, with_the_client: 3, canceled: 4, empty_stock: 5 }

  def update_stock(diff:, is_quantity_lower:)
    if is_quantity_lower
      item.increment(:quantity_stock, diff)
    else
      item.decrement(:quantity_stock, diff)
    end
  end

  def dish?
    item_type == 'Dish'
  end

  def quantity_lower?(new_quantity:)
    quantity < new_quantity
  end

  def set_default_status
    self.status = 3
  end

  def message(action)
    json = ApplicationController.render(template: 'api/v1/kitchens/_kitchen', locals: { kitchen: self })
    msg = {
      obj: json,
      action:
    }
    ActionCable.server.broadcast("kitchens_#{order.organization.id}", msg.to_json)
  end

  private

  def enqueue_reindex_job
    ReindexJob.perform_async(self.class.name)
  end

  def recalculate_total
    order.recalculate_total
  end

  def reset_stock
    item.increment(:quantity_stock, quantity)
  end

  def decrement_stock
    item.decrement(:quantity_stock, quantity)
  end
end
