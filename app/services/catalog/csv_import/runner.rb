# frozen_string_literal: true

module Catalog
  module CsvImport
    class Runner
      def initialize(import)
        @import = import
      end

      def call
        table = Table.parse(StringIO.new(@import.file.download), product_type: @import.product_type)
        @import.update!(total_rows: table.rows.size)
        creator = Creator.new(@import.organization, @import.product_type)
        table.rows.each { |row| record(creator.create(row)) }
      end

      private

      def record(entry)
        created = entry['status'] == 'created'
        @import.update!(
          row_log: @import.row_log + [entry],
          processed_rows: @import.processed_rows + 1,
          created_rows: @import.created_rows + (created ? 1 : 0),
          failed_rows: @import.failed_rows + (created ? 0 : 1)
        )
      end
    end
  end
end
