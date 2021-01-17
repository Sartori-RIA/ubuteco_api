class AddOrganizationToTables < ActiveRecord::Migration[6.0]
  def change
    add_reference :tables, :organization, foreign_key: true, on_delete: :cascade
  end
end
