class AddUserToTables < ActiveRecord::Migration[5.2]
  def change
    add_reference :tables, :user, foreign_key: true
  end
end
