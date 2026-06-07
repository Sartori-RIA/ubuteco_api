# frozen_string_literal: true

class CreateStockMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_movements do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :product, polymorphic: true, null: false
      t.integer :delta, null: false
      t.string :reason
      t.references :user, foreign_key: true
      t.references :order_item, foreign_key: true

      t.timestamps
    end

    add_index :stock_movements, %i[organization_id created_at]
  end
end
