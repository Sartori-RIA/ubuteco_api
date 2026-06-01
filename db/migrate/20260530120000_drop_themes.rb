# frozen_string_literal: true

class DropThemes < ActiveRecord::Migration[8.1]
  def up
    drop_table :themes, if_exists: true
  end

  def down
    create_table :themes do |t|
      t.string :color_footer
      t.string :color_header
      t.string :color_sidebar
      t.string :name
      t.references :organization, foreign_key: true

      t.timestamps
    end
  end
end
