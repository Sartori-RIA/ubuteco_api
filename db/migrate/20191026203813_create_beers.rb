class CreateBeers < ActiveRecord::Migration[5.2]
  def change
    create_table :beers do |t|
      t.string :name
      t.monetize :price
      t.string :image
      t.integer :quantity_stock
      t.text :description
      t.decimal :abv
      t.decimal :ibu
      t.datetime :valid_until
      t.references :maker, foreign_key: true
      t.references :beer_style, foreign_key: true
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :beers, :deleted_at
  end
end
