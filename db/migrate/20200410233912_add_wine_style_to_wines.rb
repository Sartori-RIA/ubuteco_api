class AddWineStyleToWines < ActiveRecord::Migration[5.2]
  def change
    add_reference :wines, :wine_style, foreign_key: true
  end
end
