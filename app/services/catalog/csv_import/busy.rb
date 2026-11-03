# frozen_string_literal: true

module Catalog
  module CsvImport
    class Busy < StandardError
      attr_reader :import

      def initialize(import)
        @import = import
        super(I18n.t('api.errors.import_in_progress'))
      end
    end
  end
end
