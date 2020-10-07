class CreateDishes < ActiveRecord::Migration[5.2]
  def change
    create_table :dishes do |t|
      t.string :name
      t.monetize :price
      t.string :image

      t.datetime :deleted_at
      t.timestamps
    end
    add_index :dishes, :deleted_at
  end
end