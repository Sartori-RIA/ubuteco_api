# frozen_string_literal: true

module Ai
  module Assistant
    module Tools
      class SalesSummary < Tool
        def self.tool_name = 'sales_summary'

        def self.description
          'Completed-order totals for a date range: revenue_cents, orders, average ticket, and currency.'
        end

        def self.input_schema
          {
            type: 'object',
            properties: {
              from: { type: 'string', description: 'Start date YYYY-MM-DD in the organization timezone' },
              to: { type: 'string', description: 'End date YYYY-MM-DD in the organization timezone' }
            },
            required: %w[from to]
          }
        end

        def self.required_ability = %i[read dashboard]

        def self.perform(organization:, args:, **)
          Organizations::Dashboard::Summary.call(org: organization, from: args['from'], to: args['to'])
        end
      end
    end
  end
end
