# frozen_string_literal: true

class CreateCatalogImports < ActiveRecord::Migration[8.1]
  def change
    create_table :catalog_imports do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :product_type, null: false
      t.string :status, null: false, default: "queued"
      t.integer :total_rows, null: false, default: 0
      t.integer :created_rows, null: false, default: 0
      t.integer :failed_rows, null: false, default: 0
      t.integer :processed_rows, null: false, default: 0
      t.text :error_message
      t.datetime :enqueued_at
      t.datetime :started_at
      t.datetime :finished_at
      t.jsonb :row_log, null: false, default: []

      t.timestamps
    end

    add_index :catalog_imports, %i[organization_id status]
  end
end
