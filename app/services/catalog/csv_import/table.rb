# frozen_string_literal: true

require 'csv'

module Catalog
  module CsvImport
    class Table
      MAX_ROWS = 500

      attr_reader :rows, :source

      def self.parse(io, product_type:)
        source = read_source(io)
        table = new(source, product_type.to_s)
        table.parse
        table
      end

      def self.read_source(io)
        raw = io.respond_to?(:read) ? read_io(io) : io.to_s.b
        raw = raw.b
        raw.delete_prefix!("\xEF\xBB\xBF".b)
        text = raw.force_encoding('UTF-8')
        raise InvalidFile, :encoding unless text.valid_encoding?

        text
      end

      def self.read_io(io)
        io.rewind if io.respond_to?(:rewind)
        data = io.read.to_s
        io.rewind if io.respond_to?(:rewind)
        data
      end

      def initialize(source, product_type)
        @source = source
        @product_type = product_type
        @rows = []
      end

      def parse
        raise InvalidFile, :unknown_type unless Columns.model_for(@product_type)
        raise InvalidFile, :empty if @source.strip.empty?

        csv = CSV.new(@source, headers: true, col_sep: delimiter)
        first = csv.shift
        raise InvalidFile, :empty if first.nil?

        check_headers(csv.headers)
        append_row(first, csv.lineno)
        csv.each { |row| append_row(row, csv.lineno) }
        raise InvalidFile, :too_many_rows if @rows.size > MAX_ROWS
      rescue CSV::MalformedCSVError
        raise InvalidFile, :malformed
      end

      private

      def delimiter
        header_line = @source.each_line.first.to_s
        header_line.count(';') > header_line.count(',') ? ';' : ','
      end

      def append_row(row, line)
        @rows << build_row(row, line)
      end

      def check_headers(headers)
        normalized = Array(headers).map { |header| header.to_s.strip.downcase }
        raise InvalidFile, :empty if normalized.all?(&:empty?)
        raise InvalidFile, :duplicate_header if normalized.uniq.size != normalized.size

        unknown = normalized - Columns.allowed_for(@product_type)
        missing = Columns.required_for(@product_type) - normalized
        raise InvalidFile.new(:unknown_header, header: unknown.first) if unknown.any?
        raise InvalidFile.new(:missing_header, header: missing.first) if missing.any?
      end

      def build_row(row, line)
        values = row.to_h.transform_keys { |key| key.to_s.strip.downcase }
        values.merge('line' => line)
      end
    end
  end
end
