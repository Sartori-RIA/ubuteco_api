class CreateOrderItems < ActiveRecord::Migration[6.0]
  def change
    create_table :order_items do |t|
      t.references :order, foreign_key: true
      t.integer :quantity
      t.references :item, polymorphic: true

      t.timestamps
    end
  end
end
