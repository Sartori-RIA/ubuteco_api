# frozen_string_literal: true

class OrderItem < ApplicationRecord
  class InsufficientStock < StandardError; end

  around_create :reserve_stock_unless_dish
  after_create :recalculate_total
  after_create :set_default_status_for_dish, if: :dish?
  after_create { |order_item| order_item.message 'create' }

  after_update :recalculate_total

  around_destroy :release_stock_unless_dish
  after_destroy :recalculate_total

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validate :item_matches_order_organization
  validate :order_must_be_open, on: :create
  validate :sufficient_stock_available, on: :create, unless: :dish?

  belongs_to :order
  belongs_to :item, polymorphic: true

  enum :status, { awaiting: 0, cooking: 1, ready: 2, with_the_client: 3, canceled: 4, empty_stock: 5 }

  def dish?
    item_type == 'Dish'
  end

  def apply_quantity_change!(previous_quantity:)
    return if dish?

    delta = quantity - previous_quantity
    return if delta.zero?

    adjust_stock!(-delta)
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

  def recalculate_total
    order.recalculate_total
  end

  def set_default_status_for_dish
    update_column(:status, self.class.statuses[:awaiting])
  end

  def reserve_stock_unless_dish
    if dish? || !stockable_item?
      yield
      return
    end

    product = item
    product.with_lock do
      yield
      product.decrement!(:quantity_stock, quantity)
    end
  end

  def release_stock_unless_dish
    if dish? || !stockable_item?
      yield
      return
    end

    product = item
    product.with_lock do
      yield
      product.increment!(:quantity_stock, quantity)
    end
  end

  def adjust_stock!(delta)
    return if dish?
    return unless stockable_item?

    product = item
    product.with_lock do
      new_stock = product.quantity_stock + delta
      if new_stock.negative?
        errors.add(:quantity, 'insufficient stock')
        raise InsufficientStock
      end

      product.update!(quantity_stock: new_stock)
    end
  end

  def stockable_item?
    item.respond_to?(:quantity_stock)
  end

  def item_matches_order_organization
    return if order.blank? || item.blank?
    return unless item.respond_to?(:organization_id)

    return if item.organization_id == order.organization_id

    errors.add(:item, 'must belong to the same organization as the order')
  end

  def order_must_be_open
    return if order.blank?

    return if order.open?

    errors.add(:order, 'must be open to add items')
  end

  def sufficient_stock_available
    return unless stockable_item?

    return if item.quantity_stock >= quantity

    errors.add(:quantity, 'insufficient stock')
  end
end
