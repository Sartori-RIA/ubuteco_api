# frozen_string_literal: true

module Inventory
  STOCKABLE_CLASSES = [Beer, Wine, Drink, Food].freeze

  PRODUCT_TYPE_KEYS = {
    'beers' => Beer,
    'wines' => Wine,
    'drinks' => Drink,
    'foods' => Food
  }.freeze

  def self.stockable?(record)
    STOCKABLE_CLASSES.any? { |klass| record.is_a?(klass) }
  end

  def self.low_stock_threshold
    ENV.fetch('LOW_STOCK_THRESHOLD', 5).to_i
  end

  def self.find_stockable!(product_type:, id:)
    klass = PRODUCT_TYPE_KEYS.fetch(product_type) { raise ActiveRecord::RecordNotFound }
    klass.find(id)
  end
end
