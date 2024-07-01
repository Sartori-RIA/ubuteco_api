class CreateAllowlistedJwts < ActiveRecord::Migration[7.1]
  def change
    create_table :allowlisted_jwts do |t|
      t.string :jti
      t.string :aud
      # If you want to leverage the `aud` claim, add to it a `NOT NULL` constraint:
      # t.string :aud, null: false
      t.datetime :exp
      t.references :user, foreign_key: { on_delete: :cascade }, null: false
      t.timestamps
    end
  end
end
