class AddWineStyleToWines < ActiveRecord::Migration[7.1]
  def change
    add_reference :wines, :wine_style, foreign_key: true
  end
end
