# frozen_string_literal: true

module Ai
  module Assistant
    module Tools
      class KitchenMetrics < Tool
        def self.tool_name = 'kitchen_metrics'

        def self.description
          'Open dishes in the kitchen and average prep seconds for a date range.'
        end

        def self.input_schema
          {
            type: 'object',
            properties: {
              from: { type: 'string' },
              to: { type: 'string' }
            },
            required: %w[from to]
          }
        end

        def self.required_ability = %i[read dashboard]

        def self.perform(organization:, args:, **)
          Organizations::Dashboard::Kitchen.call(org: organization, from: args['from'], to: args['to'])
        end
      end
    end
  end
end
