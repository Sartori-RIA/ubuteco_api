class AddOrganizationToTables < ActiveRecord::Migration[6.0]
  def change
    add_reference :tables, :organization, foreign_key: true
  end
end