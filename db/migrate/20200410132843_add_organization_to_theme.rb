class AddUserToTheme < ActiveRecord::Migration[5.2]
  def change
    add_reference :themes, :organization, foreign_key: true
  end
end
