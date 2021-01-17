class AddOrganizationToTheme < ActiveRecord::Migration[6.0]
  def change
    add_reference :themes, :organization, foreign_key: true, on_delete: :cascade
  end
end
