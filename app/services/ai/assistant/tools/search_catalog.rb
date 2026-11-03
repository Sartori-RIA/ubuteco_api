# frozen_string_literal: true

module Ai
  module Assistant
    module Tools
      class SearchCatalog < Tool
        MODELS = Catalog::EmbeddingText::MODELS.values.freeze
        PER_MODEL = 5

        def self.tool_name = 'search_catalog'

        def self.description
          'Find beers, wines, drinks, foods, and dishes by name or description.'
        end

        def self.input_schema
          {
            type: 'object',
            properties: {
              query: { type: 'string' }
            },
            required: ['query']
          }
        end

        def self.perform(ability:, organization:, args:, **)
          query = args['query'].to_s.strip
          raise ArgumentError, 'query is required' if query.blank?

          readable = MODELS.select { |model| ability.can?(:read, model) }
          return { error: 'not_allowed' } if readable.empty?

          items = readable.flat_map { |model| search_one(model, query, organization) }
          { items: items.first(15) }
        end

        def self.search_one(model, query, organization)
          where = { organization_id: organization.id }
          records = Catalog::SemanticSearch.call(
            model:, query:, where:, mode: 'hybrid', organization:
          )
          records = keyword_search(model, query, where) if records.nil?
          Array(records).first(PER_MODEL).map { |record| serialize(record) }
        end

        def self.keyword_search(model, query, where)
          model.search(query, where:, limit: PER_MODEL)
        rescue Searchkick::Error, Faraday::Error
          []
        end

        def self.serialize(record)
          {
            product_type: record.model_name.route_key,
            id: record.id,
            name: record.name,
            price_cents: record.price_cents
          }
        end
      end
    end
  end
end
