# frozen_string_literal: true

class AddCatalogEmbeddings < ActiveRecord::Migration[8.1]
  TABLES = %i[beers wines drinks foods dishes].freeze

  def change
    TABLES.each do |table_name|
      add_column table_name, :embedding, :jsonb
      add_column table_name, :embedding_digest, :string
    end
  end
end
