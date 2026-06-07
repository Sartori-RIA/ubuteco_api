# frozen_string_literal: true

class OrderItem < ApplicationRecord
  class InsufficientStock < StandardError; end

  include OrderItemStateMachine

  around_create :reserve_stock_unless_dish
  after_create :recalculate_total
  after_create :record_stock_movement_on_create, unless: :dish?
  after_update :record_stock_movement_on_quantity_change, if: :saved_change_to_quantity?
  after_create_commit :broadcast_kitchen_create, if: :dish?

  after_update :recalculate_total
  after_update_commit :broadcast_kitchen_status, if: :dish?

  around_destroy :release_stock_unless_dish
  after_destroy :recalculate_total
  after_destroy :record_stock_movement_on_destroy, unless: :dish?

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validate :item_matches_order_organization
  validate :item_currency_matches_order, on: :create
  validate :order_must_be_open, on: :create
  validate :sufficient_stock_available, on: :create, unless: :dish?

  belongs_to :order
  belongs_to :item, polymorphic: true

  enum :status, { awaiting: 0, cooking: 1, ready: 2, with_the_client: 3, canceled: 4, empty_stock: 5 }

  KITCHEN_ACTIVE_STATUSES = %w[awaiting cooking ready].freeze

  scope :kitchen_queue_for, lambda { |organization_id|
    joins(:order)
      .where(item_type: 'Dish')
      .where(orders: { organization_id: organization_id, status: Order.statuses[:open] })
  }

  scope :kitchen_active, -> { where(status: KITCHEN_ACTIVE_STATUSES) }

  def dish?
    item_type == 'Dish'
  end

  def apply_quantity_change!(previous_quantity:)
    return if dish?

    delta = quantity - previous_quantity
    return if delta.zero?

    adjust_stock!(-delta)
  end

  def broadcast_kitchen_create
    Kitchen::BroadcastOrderItem.call(order_item: self, action: "create")
  end

  def broadcast_kitchen_status
    return unless saved_change_to_status?

    Kitchen::BroadcastOrderItem.call(order_item: self, action: "update")
  end

  private

  def recalculate_total
    order.recalculate_total
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
        errors.add(:quantity, :insufficient_stock)
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

    errors.add(:item, :organization_mismatch)
  end

  def item_currency_matches_order
    return if order.blank? || item.blank?
    return unless item.respond_to?(:price_currency)

    order_currency = order.total_currency
    return if order_currency.blank?

    return if item.price_currency.to_s.upcase == order_currency.to_s.upcase

    errors.add(:item, :currency_mismatch)
  end

  def order_must_be_open
    return if order.blank?

    return if order.open?

    errors.add(:order, :must_be_open)
  end

  def sufficient_stock_available
    return unless stockable_item?

    return if item.quantity_stock >= quantity

    errors.add(:quantity, :insufficient_stock)
  end

  def record_stock_movement_on_create
    return unless stockable_item?

    Inventory::RecordMovement.call(
      organization: order.organization,
      product: item,
      delta: -quantity,
      order_item: self
    )
  end

  def record_stock_movement_on_destroy
    return unless stockable_item?

    Inventory::RecordMovement.call(
      organization: order.organization,
      product: item,
      delta: quantity,
      order_item: self
    )
  end

  def record_stock_movement_on_quantity_change
    return if dish? || !stockable_item?

    previous_quantity, = saved_change_to_quantity
    stock_delta = previous_quantity - quantity
    return if stock_delta.zero?

    Inventory::RecordMovement.call(
      organization: order.organization,
      product: item,
      delta: stock_delta,
      order_item: self
    )
  end
end
