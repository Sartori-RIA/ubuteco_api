class CreateWines < ActiveRecord::Migration[5.2]
  def change
    create_table :wines do |t|
      t.string :name
      t.integer :quantity_stock
      t.string :image
      t.decimal :abv
      t.monetize :price
      t.text :description
      t.references :maker, foreign_key: true
      t.integer :vintage_wine
      t.string :visual
      t.string :ripening
      t.string :grapes
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :wines, :deleted_at
  end
end
