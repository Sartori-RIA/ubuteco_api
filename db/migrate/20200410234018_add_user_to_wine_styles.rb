class AddUserToWineStyles < ActiveRecord::Migration[5.2]
  def change
    add_reference :wine_styles, :user, foreign_key: true
  end
end
