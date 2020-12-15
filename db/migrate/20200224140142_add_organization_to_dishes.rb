class AddOrganizationToDishes < ActiveRecord::Migration[6.0]
  def change
    add_reference :dishes, :organization, foreign_key: true
  end
end
