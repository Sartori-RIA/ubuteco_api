class CreateBeerStyles < ActiveRecord::Migration[7.1]
  def change
    create_table :beer_styles do |t|
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :beer_styles, :deleted_at
    add_index :beer_styles, :name, unique: true
  end
end
