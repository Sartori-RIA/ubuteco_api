class CreateTables < ActiveRecord::Migration[6.0]
  def change
    create_table :tables do |t|
      t.string :name
      t.integer :chairs
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :tables, :deleted_at
  end
end
