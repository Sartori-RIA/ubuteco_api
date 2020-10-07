# frozen_string_literal: true

class Order < ApplicationRecord
  acts_as_paranoid

  belongs_to :table, optional: true
  belongs_to :user
  has_many :order_items, dependent: :destroy

  monetize :total_cents, :total_with_discount_cents, :discount_cents
end
