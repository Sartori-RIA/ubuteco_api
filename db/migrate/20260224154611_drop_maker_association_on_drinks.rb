class DropMakerAssociationOnDrinks < ActiveRecord::Migration[8.1]
  def change
    remove_reference :drinks, :maker
  end
end
