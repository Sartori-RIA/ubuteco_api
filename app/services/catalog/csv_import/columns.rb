# frozen_string_literal: true

require 'csv'

module Catalog
  module CsvImport
    class Columns
      TYPES = {
        'beer' => {
          model: Beer,
          required: %w[name price ibu abv maker beer_style],
          optional: %w[quantity_stock description valid_until],
          example: ['Pilsen', '12.50', '15', '4.8', 'Existing Maker', 'Pilsen', '24', 'Crisp lager', '2026-12-31']
        },
        'drink' => {
          model: Drink,
          required: %w[name price],
          optional: %w[quantity_stock description flavor],
          example: ['Soda', '8.00', '12', 'Cold', 'Cola']
        },
        'wine' => {
          model: Wine,
          required: %w[name price abv description vintage_wine visual ripening grapes maker wine_style],
          optional: %w[quantity_stock],
          example: ['Reserva', '80.00', '13.5', 'Red', '2018', 'Ruby', 'Oak', 'Merlot', 'Existing Maker', 'Tinto', '6']
        },
        'food' => {
          model: Food,
          required: %w[name price],
          optional: %w[quantity_stock valid_until],
          example: ['Pão francês', '1.50', '40', '2026-12-31']
        },
        'dish' => {
          model: Dish,
          required: %w[name price],
          optional: %w[ingredients],
          example: ['Misto quente', '18.00', 'Pão francês:1|Queijo:1']
        }
      }.freeze

      def self.model_for(product_type)
        TYPES.dig(product_type.to_s, :model)
      end

      def self.required_for(product_type)
        TYPES.fetch(product_type.to_s).fetch(:required)
      end

      def self.allowed_for(product_type)
        spec = TYPES.fetch(product_type.to_s)
        spec.fetch(:required) + spec.fetch(:optional)
      end

      def self.template_csv(product_type)
        headers = allowed_for(product_type)
        CSV.generate do |csv|
          csv << headers
          csv << TYPES.fetch(product_type.to_s).fetch(:example)
        end
      end
    end
  end
end
