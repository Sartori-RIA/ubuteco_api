# frozen_string_literal: true

module Catalog
  module CsvImport
    class InvalidFile < StandardError
      def initialize(key, **)
        super(I18n.t("catalog_import.file.#{key}", **))
      end
    end
  end
end
