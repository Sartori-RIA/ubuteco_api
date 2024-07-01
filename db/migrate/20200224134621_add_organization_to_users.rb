class AddOrganizationToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :organization, foreign_key: true
  end
end
