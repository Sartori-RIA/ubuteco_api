class AddOrganizationToDrinks < ActiveRecord::Migration[6.0]
  def change
    add_reference :drinks, :organization, foreign_key: true
  end
end
