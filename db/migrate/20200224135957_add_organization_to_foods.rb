class AddOrganizationToFoods < ActiveRecord::Migration[7.1]
  def change
    add_reference :foods, :organization, foreign_key: true
  end
end
