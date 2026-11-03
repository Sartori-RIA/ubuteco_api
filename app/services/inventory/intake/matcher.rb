# frozen_string_literal: true

module Inventory
  module Intake
    class Matcher
      MODELS = [Beer, Wine, Drink, Food].freeze

      def self.call(organization:, lines:)
        new(organization:).call(lines)
      end

      def initialize(organization:)
        @organization = organization
      end

      def call(lines)
        lines.map { |line| line.merge(match: match_line(line[:description] || line['description'])) }
      end

      private

      attr_reader :organization

      def match_line(description)
        needle = description.to_s.strip
        return if needle.blank?

        exact = find_exact(needle)
        return payload(exact, 'high') if exact

        semantic = find_semantic(needle)
        return payload(semantic, confidence_for(semantic, needle)) if semantic

        loose = find_loose(needle)
        payload(loose, 'low') if loose
      end

      def find_exact(needle)
        MODELS.lazy.filter_map { |model| scoped(model).where('LOWER(name) = ?', needle.downcase).first }.first
      end

      def find_loose(needle)
        pattern = "%#{ActiveRecord::Base.sanitize_sql_like(needle)}%"
        MODELS.lazy.filter_map { |model| scoped(model).where('name ILIKE ?', pattern).first }.first
      end

      def find_semantic(needle)
        return unless Ai.enabled_for?(organization)

        MODELS.each do |model|
          records = Catalog::SemanticSearch.call(
            model:,
            query: needle,
            where: { organization_id: organization.id },
            mode: 'hybrid',
            organization:
          )
          hit = Array(records).first
          return hit if hit
        rescue Searchkick::Error, Faraday::Error, Ai::Error
          next
        end
        nil
      end

      def scoped(model)
        model.where(organization_id: organization.id)
      end

      def confidence_for(record, needle)
        record.name.to_s.casecmp(needle).zero? ? 'high' : 'low'
      end

      def payload(record, confidence)
        {
          product_type: record.model_name.route_key,
          id: record.id,
          name: record.name,
          confidence:
        }
      end
    end
  end
end
