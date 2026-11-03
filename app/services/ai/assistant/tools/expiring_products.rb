# frozen_string_literal: true

module Ai
  module Assistant
    module Tools
      class ExpiringProducts < Tool
        def self.tool_name = 'expiring_products'

        def self.description
          'Products that expire soon or are already expired, using the organization calendar.'
        end

        def self.input_schema
          { type: 'object', properties: {} }
        end

        def self.required_ability = %i[read inventory]

        def self.perform(organization:, **)
          items = Inventory::ExpiringProductsQuery.call(organization:)
          { count: items.size, items: items.first(LIST_LIMIT) }
        end
      end
    end
  end
end
