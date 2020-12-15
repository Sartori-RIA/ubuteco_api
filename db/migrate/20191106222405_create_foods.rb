class CreateFoods < ActiveRecord::Migration[6.0]
  def change
    create_table :foods do |t|
      t.string :name
      t.monetize :price
      t.string :image
      t.integer :quantity_stock
      t.datetime :valid_until
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :foods, :deleted_at
  end
end
