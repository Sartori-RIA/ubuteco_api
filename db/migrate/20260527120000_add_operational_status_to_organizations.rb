# frozen_string_literal: true

class AddOperationalStatusToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :operational_status, :integer, default: 0, null: false
  end
end
