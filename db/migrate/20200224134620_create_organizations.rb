class CreateOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :phone
      t.string :logo
      t.references :user, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :organizations, :phone, unique: true
    add_index :organizations, :deleted_at
  end
end
