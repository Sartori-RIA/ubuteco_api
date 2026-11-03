# frozen_string_literal: true

module Inventory
  module Intake
    class NfeXmlParser
      class Invalid < StandardError; end

      def self.call(xml)
        new(xml).call
      end

      def initialize(xml)
        @xml = xml
      end

      def call
        products.filter_map { |node| line_for(node) }.tap do |lines|
          raise Invalid if lines.empty?
        end
      rescue Nokogiri::XML::SyntaxError, ArgumentError
        raise Invalid
      end

      private

      attr_reader :xml

      def products
        document = Nokogiri::XML(xml) { |config| config.strict.nonet }
        document.remove_namespaces!
        raise Invalid if document.at_xpath('//infNFe').nil?

        document.xpath('//det/prod')
      end

      def line_for(node)
        description = node.at_xpath('xProd')&.text.to_s.strip
        return if description.blank?

        quantity = decimal(node.at_xpath('qCom')&.text)
        cost = decimal(node.at_xpath('vUnCom')&.text)
        {
          description:,
          ean: ean_for(node),
          quantity: whole?(quantity) ? quantity.to_i : quantity.to_f,
          unit: node.at_xpath('uCom')&.text.to_s.strip,
          unit_cost_cents: (cost * 100).round(0).to_i,
          source: 'xml'
        }
      end

      def ean_for(node)
        raw = node.at_xpath('cEAN')&.text.to_s.strip
        return if raw.blank? || raw.casecmp('SEM GTIN').zero?

        raw
      end

      def decimal(value)
        BigDecimal(value.to_s)
      end

      def whole?(quantity)
        quantity.frac.zero?
      end
    end
  end
end
