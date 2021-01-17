class AddOrganizationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :organization, foreign_key: true, on_delete: :cascade
  end
end
