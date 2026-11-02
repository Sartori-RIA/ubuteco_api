# frozen_string_literal: true

class AddAiFoundation < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :ai_enabled, :boolean, default: false, null: false

    create_table :ai_usage_events do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :feature, null: false
      t.string :model
      t.integer :input_tokens, null: false, default: 0
      t.integer :output_tokens, null: false, default: 0
      t.integer :latency_ms
      t.string :status, null: false
      t.timestamps
    end

    add_index :ai_usage_events, %i[organization_id created_at]
  end
end
