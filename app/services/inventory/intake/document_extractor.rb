# frozen_string_literal: true

module Inventory
  module Intake
    class DocumentExtractor
      include JsonOutput

      PROMPT = Rails.root.join('app/prompts/intake/document.md.erb')

      def self.call(organization:, user:, bytes:, media_type:)
        new(organization:, user:, bytes:, media_type:).call
      end

      def initialize(organization:, user:, bytes:, media_type:)
        @organization = organization
        @user = user
        @bytes = bytes
        @media_type = media_type
      end

      def call
        parsed.filter_map { |row| line_for(row) }.tap do |lines|
          raise Ai::InvalidOutputError if lines.empty?
        end
      end

      private

      attr_reader :organization, :user, :bytes, :media_type

      def parsed
        result = Ai::Client.complete(
          feature: Ai::Feature::PRODUCT_INTAKE,
          tier: :smart,
          system: prompt,
          messages: [{ role: 'user', content: content }],
          organization:,
          user:
        )
        value = parse_json(result.text)
        raise Ai::InvalidOutputError unless value.is_a?(Array)

        value
      end

      def line_for(row)
        raise Ai::InvalidOutputError unless row.is_a?(Hash)

        description = row['description'].to_s.strip
        return if description.blank?

        {
          description:,
          ean: row['ean'].presence,
          quantity: number(row['quantity']),
          unit: row['unit'].to_s,
          unit_cost_cents: integer(row['unit_cost_cents']),
          source: 'ai'
        }
      end

      def number(value)
        raise Ai::InvalidOutputError unless value.is_a?(Numeric)

        value
      end

      def integer(value)
        raise Ai::InvalidOutputError unless value.is_a?(Numeric)

        value.to_i
      end

      def content
        [
          { type: block_type, source: { type: 'base64', media_type:, data: Base64.strict_encode64(bytes) } },
          { type: 'text', text: 'Extract the invoice lines.' }
        ]
      end

      def block_type
        media_type == 'application/pdf' ? 'document' : 'image'
      end

      def prompt
        ERB.new(PROMPT.read).result_with_hash(locale: I18n.locale.to_s)
      end
    end
  end
end
