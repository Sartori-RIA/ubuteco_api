class AddOrganizationToWines < ActiveRecord::Migration[6.0]
  def change
    add_reference :wines, :organization, foreign_key: true
  end
end
