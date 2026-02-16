# frozen_string_literal: true

class DropImageColumns < ActiveRecord::Migration[8.1]
  def change
    remove_column :wines, :image
    remove_column :beers, :image
    remove_column :drinks, :image
    remove_column :foods, :image
    remove_column :dishes, :image
    remove_column :users, :avatar
    remove_column :organizations, :logo
  end
end
