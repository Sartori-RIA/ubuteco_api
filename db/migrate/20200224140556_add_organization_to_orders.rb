class AddOrganizationToOrders < ActiveRecord::Migration[6.0]
  def change
    add_reference :orders, :organization, foreign_key: true, on_delete: :cascade
  end
end
