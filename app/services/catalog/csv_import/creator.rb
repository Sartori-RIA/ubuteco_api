# frozen_string_literal: true

module Catalog
  module CsvImport
    class Creator
      def initialize(organization, product_type)
        @organization = organization
        @product_type = product_type
        @seen = Set.new
      end

      def create(row)
        errors = []
        name = row['name'].to_s.strip
        errors << I18n.t('catalog_import.errors.name_taken') if taken?(name)
        record = build(row, errors) if errors.empty?
        return entry(row, name, 'failed', errors) if errors.any?

        save(row, name, record)
      end

      private

      def build(row, errors)
        case @product_type
        when 'beer' then beer(row, errors)
        when 'drink' then drink(row, errors)
        when 'wine' then wine(row, errors)
        when 'food' then food(row, errors)
        when 'dish' then dish(row, errors)
        end
      end

      def beer(row, errors)
        maker = named(Maker.where(organization_id: @organization.id), row['maker'], :maker_missing, errors)
        style = named(BeerStyle.all, row['beer_style'], :beer_style_missing, errors)
        return if errors.any?

        Beer.new(stocked(row, errors).merge(beer_attributes(row, errors, maker, style)))
      end

      def drink(row, errors)
        Drink.new(stocked(row, errors).merge(description: text(row['description']), flavor: text(row['flavor'])))
      end

      def wine(row, errors)
        maker = named(Maker.where(organization_id: @organization.id), row['maker'], :maker_missing, errors)
        style = named(WineStyle.all, row['wine_style'], :wine_style_missing, errors)
        return if errors.any?

        Wine.new(stocked(row, errors).merge(wine_attributes(row, errors, maker, style)))
      end

      def food(row, errors)
        Food.new(stocked(row, errors).merge(valid_until: date(row['valid_until'], errors)))
      end

      def dish(row, errors)
        pairs = Ingredients.parse(row['ingredients'], organization: @organization, errors:)
        return if errors.any?

        record = Dish.new(identity(row, errors))
        pairs.each { |item, quantity| record.dish_ingredients.build(food: item, quantity:) }
        record
      end

      def beer_attributes(row, errors, maker, style)
        {
          description: text(row['description']),
          valid_until: date(row['valid_until'], errors),
          ibu: number(row['ibu'], errors),
          abv: number(row['abv'], errors),
          maker:,
          beer_style: style
        }
      end

      def wine_attributes(row, errors, maker, style)
        {
          abv: number(row['abv'], errors),
          description: text(row['description']),
          vintage_wine: integer_value(row['vintage_wine'], errors),
          visual: text(row['visual']),
          ripening: text(row['ripening']),
          grapes: text(row['grapes']),
          maker:,
          wine_style: style
        }
      end

      def stocked(row, errors)
        identity(row, errors).merge(quantity_stock: stock(row['quantity_stock'], errors))
      end

      def identity(row, errors)
        {
          organization: @organization,
          name: row['name'].to_s.strip,
          price: number(row['price'], errors),
          price_currency: @organization.default_currency
        }
      end

      def named(scope, raw, key, errors)
        name = raw.to_s.strip
        found = scope.where('LOWER(name) = ?', name.downcase).first if name.present?
        errors << I18n.t("catalog_import.errors.#{key}", name:) if found.nil?
        found
      end

      def number(raw, errors)
        text = raw.to_s.strip
        return if text.blank?

        Decimal.parse(text)
      rescue Decimal::InvalidNumber
        errors << I18n.t('catalog_import.errors.invalid_number')
        nil
      end

      def integer_value(raw, errors)
        value = number(raw, errors)
        return if value.nil? || errors.any?
        return value.to_i if value.frac.zero? && value.negative? == false

        errors << I18n.t('catalog_import.errors.invalid_number')
        nil
      end

      def stock(raw, errors)
        return 0 if raw.to_s.strip.blank?

        integer_value(raw, errors)
      end

      def date(raw, errors)
        text = raw.to_s.strip
        return if text.blank?

        Date.iso8601(text)
      rescue Date::Error
        errors << I18n.t('catalog_import.errors.invalid_date')
        nil
      end

      def text(raw)
        value = raw.to_s.strip
        value.presence
      end

      def taken?(name)
        return false if name.blank?

        key = name.downcase
        @seen.include?(key) || model.where(organization_id: @organization.id).exists?(['LOWER(name) = ?', key])
      end

      def model
        Columns.model_for(@product_type)
      end

      def save(row, name, record)
        saved = false
        ActiveRecord::Base.transaction do
          saved = record.save
          raise ActiveRecord::Rollback unless saved
        end
        return entry(row, row['name'].to_s.strip, 'failed', record.errors.full_messages) unless saved

        @seen.add(name.downcase)
        entry(row, name, 'created', [])
      end

      def entry(row, name, status, errors)
        { 'line' => row['line'], 'name' => name, 'status' => status, 'errors' => errors }
      end
    end
  end
end
