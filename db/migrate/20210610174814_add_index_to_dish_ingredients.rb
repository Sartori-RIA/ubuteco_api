class AddIndexToDishIngredients < ActiveRecord::Migration[6.1]
  def change
    add_index :dish_ingredients, [ :food_id, :dish_id], name: "dish_and_food_ingredient", unique: true
  end
end
