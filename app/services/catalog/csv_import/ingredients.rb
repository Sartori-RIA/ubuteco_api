# frozen_string_literal: true

module Catalog
  module CsvImport
    class Ingredients
      def self.parse(raw, organization:, errors:)
        text = raw.to_s.strip
        return [] if text.blank?

        seen = []
        text.split('|').filter_map { |part| one(part, organization, errors, seen) }
      end

      def self.one(part, organization, errors, seen)
        name, quantity = split(part, errors)
        return if name.nil?

        food = find_food(name, organization, errors)
        return if food.nil? || duplicate?(food, seen, errors)

        seen << food.id
        [food, quantity]
      end

      def self.split(part, errors)
        name, separator, raw_quantity = part.rpartition(':')
        if separator.empty?
          errors << I18n.t('catalog_import.errors.invalid_ingredient')
          return [nil, nil]
        end

        [name.strip, quantity(raw_quantity, errors)]
      end

      def self.quantity(raw, errors)
        number = Decimal.parse(raw)
        raise Decimal::InvalidNumber unless number.positive?

        number
      rescue Decimal::InvalidNumber
        errors << I18n.t('catalog_import.errors.invalid_number')
        nil
      end

      def self.find_food(name, organization, errors)
        food = Food.where(organization_id: organization.id).where('LOWER(name) = ?', name.downcase).first
        errors << I18n.t('catalog_import.errors.food_missing', name:) if food.nil?
        food
      end

      def self.duplicate?(food, seen, errors)
        return false unless seen.include?(food.id)

        errors << I18n.t('catalog_import.errors.duplicate_ingredient', name: food.name)
        true
      end
    end
  end
end
