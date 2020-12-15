class AddCustomerToOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :customer_id, :integer, null: true, foreign_key: :users
  end
end
