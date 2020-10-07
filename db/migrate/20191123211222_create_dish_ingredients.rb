class CreateDishIngredients < ActiveRecord::Migration[5.2]
  def change
    create_table :dish_ingredients do |t|
      t.references :food, foreign_key: true
      t.references :dish, foreign_key: true
      t.decimal :quantity

      t.timestamps
    end
  end
end