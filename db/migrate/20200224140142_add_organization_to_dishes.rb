class AddOrganizationToDishes < ActiveRecord::Migration[7.1]
  def change
    add_reference :dishes, :organization, foreign_key: true
  end
end
