class AddUserToBeers < ActiveRecord::Migration[5.2]
  def change
    add_reference :beers, :user, foreign_key: true
  end
end
