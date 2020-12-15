class AddUserToMakers < ActiveRecord::Migration[5.2]
  def change
    add_reference :makers, :user, foreign_key: true
  end
end
