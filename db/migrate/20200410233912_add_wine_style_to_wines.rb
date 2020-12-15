class AddWineStyleToWines < ActiveRecord::Migration[6.0]
  def change
    add_reference :wines, :wine_style, foreign_key: true
  end
end
