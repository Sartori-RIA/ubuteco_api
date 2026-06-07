# frozen_string_literal: true

class NullifyStockMovementsOrderItemForeignKey < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :stock_movements, :order_items
    add_foreign_key :stock_movements, :order_items, on_delete: :nullify
  end
end
