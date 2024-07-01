class AddOrganizationToDrinks < ActiveRecord::Migration[7.1]
  def change
    add_reference :drinks, :organization, foreign_key: true
  end
end
