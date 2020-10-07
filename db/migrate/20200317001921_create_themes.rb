class CreateThemes < ActiveRecord::Migration[5.2]
  def change
    create_table :themes do |t|
      t.string :name
      t.string :color_header
      t.string :color_sidebar
      t.string :color_footer
      t.boolean :rtl
      t.timestamps
    end
  end
end
