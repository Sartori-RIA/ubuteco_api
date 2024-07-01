class AddOrganizationToTheme < ActiveRecord::Migration[7.1]
  def change
    add_reference :themes, :organization, foreign_key: true
  end
end
