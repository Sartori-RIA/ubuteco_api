# frozen_string_literal: true

module Ai
  module Assistant
    module Tools
      class LowStock < Tool
        def self.tool_name = 'low_stock'

        def self.description
          'Products whose stock is at or below the organization threshold.'
        end

        def self.input_schema
          { type: 'object', properties: {} }
        end

        def self.required_ability = %i[read inventory]

        def self.perform(organization:, **)
          items = Inventory::LowStockQuery.call(organization_id: organization.id)
          { count: items.size, items: items.first(LIST_LIMIT) }
        end
      end
    end
  end
end
