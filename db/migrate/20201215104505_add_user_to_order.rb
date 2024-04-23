class AddUserToOrder < ActiveRecord::Migration[7.1]
  def change
    add_reference :orders, :user, null: true, foreign_key: true
  end
end
