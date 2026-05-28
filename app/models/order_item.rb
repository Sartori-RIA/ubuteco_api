# frozen_string_literal: true

class OrderItem < ApplicationRecord
  class InsufficientStock < StandardError; end

  around_create :reserve_stock_unless_dish
  before_validation :set_default_status_for_dish, on: :create, if: :dish?
  after_create :recalculate_total
  after_create_commit :broadcast_kitchen_create, if: :dish?

  after_update :recalculate_total
  after_update_commit :broadcast_kitchen_status, if: :dish?

  around_destroy :release_stock_unless_dish
  after_destroy :recalculate_total

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validate :item_matches_order_organization
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
    unless kitchen_broadcastable?
      log_kitchen_broadcast_skipped('create')
      return
    end

    message('create')
  end

  def message(action)
    record = OrderItem.includes(:item, order: :table).find(id)
    payload = ApplicationController.render(
      template: 'api/v1/kitchens/_kitchen',
      locals: { kitchen: record }
    )
    msg = {
      obj: JSON.parse(payload),
      action:
    }
    Rails.logger.info(
      "[KitchenCable] broadcast #{action} order_item=#{record.id} org=#{record.order.organization_id}"
    )
    KitchenCableBroadcaster.deliver(organization_id: record.order.organization_id, message: msg)
  end

  def broadcast_kitchen_status
    unless kitchen_broadcastable?
      log_kitchen_broadcast_skipped('update')
      return
    end

    message('update') if saved_change_to_status?
  end

  private

  def kitchen_broadcastable?
    order.open? && order.organization.reload.open?
  end

  def log_kitchen_broadcast_skipped(action)
    org = order.organization
    Rails.logger.info(
      "[KitchenCable] skipped broadcast #{action} order_item=#{id} " \
      "order_open=#{order.open?} org_open=#{org.open?} org_id=#{org.id}"
    )
  end

  def recalculate_total
    order.recalculate_total
  end

  def set_default_status_for_dish
    self.status ||= :awaiting
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
