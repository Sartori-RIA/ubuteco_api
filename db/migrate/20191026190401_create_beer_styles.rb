class CreateBeerStyles < ActiveRecord::Migration[6.0]
  def change
    create_table :beer_styles do |t|
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :beer_styles, :deleted_at
  end
end
