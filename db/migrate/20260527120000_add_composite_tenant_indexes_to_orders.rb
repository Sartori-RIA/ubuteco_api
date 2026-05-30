# frozen_string_literal: true

class AddCompositeTenantIndexesToOrders < ActiveRecord::Migration[8.1]
  def change
    add_index :orders, %i[organization_id status], name: 'index_orders_on_organization_id_and_status'
    add_index :orders, %i[organization_id created_at], name: 'index_orders_on_organization_id_and_created_at'
  end
end
