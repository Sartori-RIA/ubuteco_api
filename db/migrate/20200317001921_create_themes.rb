class CreateThemes < ActiveRecord::Migration[7.1]
  def change
    create_table :themes do |t|
      t.string :name
      t.string :color_header
      t.string :color_sidebar
      t.string :color_footer
      t.timestamps
    end
  end
end
