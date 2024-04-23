class AddOrganizationToTables < ActiveRecord::Migration[7.1]
  def change
    add_reference :tables, :organization, foreign_key: true
  end
end
