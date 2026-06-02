# frozen_string_literal: true

class AddDashboardIndexesToOrders < ActiveRecord::Migration[8.1]
  def change
    add_index :orders, %i[organization_id created_at],
              name: 'index_orders_on_organization_id_and_created_at',
              if_not_exists: true
    add_index :orders, %i[organization_id status created_at],
              name: 'index_orders_on_organization_id_status_and_created_at',
              if_not_exists: true
  end
end
