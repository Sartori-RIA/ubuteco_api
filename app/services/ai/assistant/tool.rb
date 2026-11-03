# frozen_string_literal: true

module Ai
  module Assistant
    class Tool
      LIST_LIMIT = 8

      def self.registry
        [
          Tools::SalesSummary,
          Tools::SalesSeries,
          Tools::KitchenMetrics,
          Tools::TopProducts,
          Tools::LowStock,
          Tools::ExpiringProducts,
          Tools::SearchCatalog
        ]
      end

      def self.find(name)
        registry.find { |tool| tool.tool_name == name.to_s }
      end

      def self.schemas
        registry.map(&:schema)
      end

      def self.schema
        { name: tool_name, description:, input_schema: }
      end

      def self.required_ability
        nil
      end

      def self.execute(ability:, organization:, user:, args:)
        ability.authorize!(*required_ability) if required_ability
        perform(ability:, organization:, user:, args: normalize(args))
      rescue CanCan::AccessDenied
        { error: 'not_allowed' }
      rescue Organizations::Dashboard::RangeParser::InvalidRange, ArgumentError => e
        { error: 'invalid_arguments', message: e.message }
      end

      def self.normalize(args)
        hash = args.respond_to?(:to_h) ? args.to_h : {}
        hash.stringify_keys
      end

      def self.perform(*)
        raise NotImplementedError
      end
    end
  end
end
