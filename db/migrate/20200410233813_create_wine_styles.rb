class CreateWineStyles < ActiveRecord::Migration[7.1]
  def change
    create_table :wine_styles do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :wine_styles, :deleted_at
    add_index :wine_styles, :name, unique: true
  end
end
