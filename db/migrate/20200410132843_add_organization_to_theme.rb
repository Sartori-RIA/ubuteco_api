class AddOrganizationToTheme < ActiveRecord::Migration[6.0]
  def change
    add_reference :themes, :organization, foreign_key: true
  end
end
