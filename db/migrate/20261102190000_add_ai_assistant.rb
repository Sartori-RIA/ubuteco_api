# frozen_string_literal: true

class AddAiAssistant < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_conversations do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :ai_conversations, %i[organization_id user_id]
    add_index :ai_conversations, :deleted_at

    create_table :ai_messages do |t|
      t.references :ai_conversation, null: false, foreign_key: true
      t.string :role, null: false
      t.jsonb :content, null: false, default: {}
      t.string :tool_name
      t.jsonb :usage
      t.timestamps
    end
  end
end
