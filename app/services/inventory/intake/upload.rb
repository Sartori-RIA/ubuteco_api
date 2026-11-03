# frozen_string_literal: true

module Inventory
  module Intake
    class Upload
      MAX_BYTES = 5.megabytes
      XML = %w[application/xml text/xml].freeze
      IMAGES = %w[image/jpeg image/png].freeze
      DOCUMENTS = (IMAGES + %w[application/pdf]).freeze

      class Invalid < StandardError; end

      def initialize(file, allowed:)
        raise Invalid if file.blank?

        @bytes = file.read
        file.rewind if file.respond_to?(:rewind)
        raise Invalid if bytes.blank? || bytes.bytesize > MAX_BYTES

        @media_type = Marcel::MimeType.for(bytes)
        raise Invalid unless accepted?(allowed)
      end

      attr_reader :bytes, :media_type

      def image_bytes
        return bytes if media_type == 'application/pdf'

        image = MiniMagick::Image.read(bytes)
        image.strip
        image.to_blob
      rescue MiniMagick::Error, MiniMagick::Invalid
        raise Invalid
      end

      private

      def accepted?(allowed)
        return true if allowed.include?(media_type)
        return false unless allowed.include?('application/xml')

        media_type == 'text/plain' && bytes.include?('<NFe')
      end
    end
  end
end
