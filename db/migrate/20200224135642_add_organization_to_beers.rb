class AddOrganizationToBeers < ActiveRecord::Migration[7.1]
  def change
    add_reference :beers, :organization, foreign_key: true
  end
end
