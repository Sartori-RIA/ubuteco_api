class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.monetize :total
      t.monetize :total_with_discount
      t.monetize :discount
      t.references :table, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :orders, :deleted_at
  end
end
