class CreateMakers < ActiveRecord::Migration[6.0]
  def change
    create_table :makers do |t|
      t.string :name
      t.string :country
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :makers, :deleted_at
  end
end
