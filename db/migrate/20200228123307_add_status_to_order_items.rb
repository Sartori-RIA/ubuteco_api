class AddStatusToOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_column :order_items, :status, :integer, default: 0
  end
end
