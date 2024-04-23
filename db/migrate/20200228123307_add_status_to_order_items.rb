class AddStatusToOrderItems < ActiveRecord::Migration[7.1]
  def change
    add_column :order_items, :status, :integer, default: 0
  end
end
