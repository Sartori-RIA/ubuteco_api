# frozen_string_literal: true

module Ai
  module Assistant
    module Tools
      class SalesSeries < Tool
        def self.tool_name = 'sales_series'

        def self.description
          'Daily revenue or order counts between two dates. metric is revenue or orders.'
        end

        def self.input_schema
          {
            type: 'object',
            properties: {
              from: { type: 'string' },
              to: { type: 'string' },
              grain: { type: 'string', description: 'Only day is supported' },
              metric: { type: 'string', description: 'revenue or orders' }
            },
            required: %w[from to]
          }
        end

        def self.required_ability = %i[read dashboard]

        def self.perform(organization:, args:, **)
          Organizations::Dashboard::Series.call(
            org: organization,
            from: args['from'],
            to: args['to'],
            grain: args['grain'].presence || 'day',
            metric: args['metric'].presence || 'revenue'
          )
        end
      end
    end
  end
end
