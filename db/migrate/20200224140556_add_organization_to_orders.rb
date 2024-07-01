class AddOrganizationToOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :orders, :organization, foreign_key: true
  end
end
