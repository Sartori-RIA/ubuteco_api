class AddUserToOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :orders, :organization, foreign_key: true
  end
end
