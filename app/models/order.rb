# frozen_string_literal: true

class Order < ApplicationRecord
  include OrganizationScoped
  include OrganizationReindexable
  include OrderStateMachine

  extend Pagy::Search

  acts_as_paranoid

  searchkick callbacks: :async

  enum :status, { open: 0, closed: 1, payed: 2 }

  belongs_to :table, optional: true
  belongs_to :organization
  belongs_to :user, optional: true

  has_many :order_items, dependent: :destroy

  monetize :total_cents, :total_with_discount_cents, :discount_cents, numericality: { greater_than_or_equal_to: 0 }

  before_validation :assign_organization_currencies, on: :create

  def recalculate_total
    total = 0
    order_items.each do |order_item|
      total += (order_item.item.price_cents * order_item.quantity)
    end
    update(total_cents: total, total_with_discount_cents: total - discount_cents)
  end

  def search_data
    {
      table: table&.name,
      user: user&.name,
      total_cents: total_cents,
      status: status,
      organization_id: organization_id,
      user_id: user_id
    }
  end

  private

  def assign_organization_currencies
    currency = organization&.default_currency
    return if currency.blank?

    self.total_currency = currency
    self.discount_currency = currency
    self.total_with_discount_currency = currency
  end
end
