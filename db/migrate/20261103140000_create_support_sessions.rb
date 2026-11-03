# frozen_string_literal: true

class CreateSupportSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :support_sessions do |t|
      t.references :actor, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.text :reason, null: false
      t.string :jti, null: false
      t.datetime :started_at, null: false
      t.datetime :expires_at, null: false
      t.datetime :ended_at
      t.timestamps
    end

    add_index :support_sessions, :actor_id, where: 'ended_at IS NULL', name: 'index_support_sessions_open_on_actor_id'
    add_index :support_sessions, :jti, unique: true

    create_table :support_session_requests do |t|
      t.references :support_session, null: false, foreign_key: { on_delete: :cascade }
      t.string :http_method, null: false
      t.string :path, null: false
      t.integer :status, null: false
      t.timestamps
    end
  end
end
