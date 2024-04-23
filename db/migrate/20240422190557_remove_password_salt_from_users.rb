# frozen_string_literal: true

class RemovePasswordSaltFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :password_salt, :string
  end
end
