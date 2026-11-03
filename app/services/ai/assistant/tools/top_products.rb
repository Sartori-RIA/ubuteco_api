# frozen_string_literal: true

module Ai
  module Assistant
    module Tools
      class TopProducts < Tool
        def self.tool_name = 'top_products'

        def self.description
          'Products that sold the most quantity in a date range. Quantity is a unit count, not money.'
        end

        def self.input_schema
          {
            type: 'object',
            properties: {
              from: { type: 'string' },
              to: { type: 'string' },
              limit: { type: 'integer', description: '1 to 10, default 5' }
            },
            required: %w[from to]
          }
        end

        def self.required_ability = %i[read dashboard]

        def self.perform(organization:, args:, **)
          items = Orders::TopProductsQuery.call(
            organization:,
            from: args['from'],
            to: args['to'],
            limit: args['limit'].presence || 5
          )
          { items: }
        end
      end
    end
  end
end
