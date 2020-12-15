# frozen_string_literal: true

class CreateDrinks < ActiveRecord::Migration[6.0]
  def change
    create_table :drinks do |t|
      t.string :name
      t.monetize :price
      t.string :image
      t.integer :quantity_stock
      t.text :description
      t.string :flavor
      t.decimal :abv
      t.references :maker, foreign_key: true
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :drinks, :deleted_at
  end
end
