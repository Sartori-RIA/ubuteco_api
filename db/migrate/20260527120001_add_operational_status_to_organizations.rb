# frozen_string_literal: true

class AddOperationalStatusToOrganizations < ActiveRecord::Migration[8.1]
  def up
    unless column_exists?(:organizations, :operational_status)
      add_column :organizations, :operational_status, :integer, default: 0, null: false
    end

    unless index_exists?(:orders, %i[organization_id status], name: 'index_orders_on_organization_id_and_status')
      add_index :orders, %i[organization_id status], name: 'index_orders_on_organization_id_and_status'
    end

    unless index_exists?(:orders, %i[organization_id created_at], name: 'index_orders_on_organization_id_and_created_at')
      add_index :orders, %i[organization_id created_at], name: 'index_orders_on_organization_id_and_created_at'
    end
  end

  def down
    remove_index :orders, name: 'index_orders_on_organization_id_and_created_at', if_exists: true
    remove_index :orders, name: 'index_orders_on_organization_id_and_status', if_exists: true
    remove_column :organizations, :operational_status if column_exists?(:organizations, :operational_status)
  end
end
