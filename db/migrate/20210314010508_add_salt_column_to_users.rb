class AddSaltColumnToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :password_salt, :string
  end
end
