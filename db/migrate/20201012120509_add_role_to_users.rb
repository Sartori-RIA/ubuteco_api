class AddRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :role, foreign_key: true
  end
end
