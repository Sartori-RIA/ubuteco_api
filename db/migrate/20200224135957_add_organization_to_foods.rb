class AddUserToFoods < ActiveRecord::Migration[5.2]
  def change
    add_reference :foods, :organization, foreign_key: true
  end
end
