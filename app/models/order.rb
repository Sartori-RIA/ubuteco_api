# frozen_string_literal: true

class Order < ApplicationRecord
  acts_as_paranoid

  enum status: { open: 0, closed: 1, payed: 2 }

  belongs_to :table, optional: true
  belongs_to :organization
  belongs_to :user, optional: true

  has_many :order_items, dependent: :destroy

  monetize :total_cents, :total_with_discount_cents, :discount_cents

  include PgSearch::Model

  pg_search_scope :search,
                  against: %w[created_at total_cents total_with_discount_cents],
                  associated_against: {
                    table: %w[name],
                    user: %w[name]
                  }

  def recalculate_total
    total = 0
    order_items.each do |order_item|
      total += (order_item.item.price_cents * order_item.quantity)
    end
    update(total_cents: total, total_with_discount_cents: total - discount_cents)
  end
end
