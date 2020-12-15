class AddUserToDishes < ActiveRecord::Migration[5.2]
  def change
    add_reference :dishes, :organization, foreign_key: true
  end
end
