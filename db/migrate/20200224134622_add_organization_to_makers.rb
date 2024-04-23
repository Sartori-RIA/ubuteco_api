class AddOrganizationToMakers < ActiveRecord::Migration[7.1]
  def change
    add_reference :makers, :organization, foreign_key: true
  end
end
