class AddOrganizationToFoods < ActiveRecord::Migration[6.0]
  def change
    add_reference :foods, :organization, foreign_key: true
  end
end
