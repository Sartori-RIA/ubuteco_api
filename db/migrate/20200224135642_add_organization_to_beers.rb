class AddOrganizationToBeers < ActiveRecord::Migration[6.0]
  def change
    add_reference :beers, :organization, foreign_key: true
  end
end
