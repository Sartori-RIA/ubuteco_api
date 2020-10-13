class AddRoleToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :role, foreign_key: true
  end
end
