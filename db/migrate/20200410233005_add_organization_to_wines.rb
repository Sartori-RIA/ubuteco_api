class AddOrganizationToWines < ActiveRecord::Migration[7.1]
  def change
    add_reference :wines, :organization, foreign_key: true
  end
end
