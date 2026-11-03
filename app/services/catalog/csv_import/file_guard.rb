# frozen_string_literal: true

module Catalog
  module CsvImport
    class FileGuard
      MAX_BYTES = 1.megabyte
      ALLOWED = %w[text/csv text/plain application/vnd.ms-excel].freeze

      def self.call(upload)
        raise InvalidFile, :missing_file if upload.blank?
        raise InvalidFile, :too_large if upload.size.to_i > MAX_BYTES
        raise InvalidFile, :bad_type unless allowed_content?(upload)
      end

      def self.allowed_content?(upload)
        sample = sample_of(upload)
        detected = Marcel::Magic.by_magic(sample)&.type
        detected.nil? || ALLOWED.include?(detected)
      end

      def self.sample_of(upload)
        upload.rewind if upload.respond_to?(:rewind)
        sample = upload.read(4096).to_s
        upload.rewind if upload.respond_to?(:rewind)
        sample
      end
    end
  end
end
