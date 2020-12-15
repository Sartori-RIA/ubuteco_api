class AddUserToDrinks < ActiveRecord::Migration[5.2]
  def change
    add_reference :drinks, :organization, foreign_key: true
  end
end
