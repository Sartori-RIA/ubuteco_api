class CreateDishIngredients < ActiveRecord::Migration[7.1]
  def change
    create_table :dish_ingredients do |t|
      t.references :food, foreign_key: true
      t.references :dish, foreign_key: true
      t.decimal :quantity, precision: 2

      t.timestamps
    end
  end
end
