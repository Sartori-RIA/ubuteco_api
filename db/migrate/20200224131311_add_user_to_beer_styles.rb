class AddUserToBeerStyles < ActiveRecord::Migration[5.2]
  def change
    add_reference :beer_styles, :user, foreign_key: true
  end
end
