# frozen_string_literal: true

module Catalog
  class EmbeddingText
    MODELS = {
      'Beer' => Beer,
      'Wine' => Wine,
      'Drink' => Drink,
      'Food' => Food,
      'Dish' => Dish
    }.freeze

    def self.for(record)
      parts = [
        record.name,
        readable(record, :description),
        readable(record, :flavor),
        readable(record, :grapes),
        style_name(record),
        maker_name(record)
      ]
      parts.concat(ingredient_names(record))
      parts.compact.map { |part| part.to_s.strip }.reject(&:empty?).uniq.join("\n")
    end

    def self.digest(record)
      Digest::SHA256.hexdigest(self.for(record))
    end

    def self.readable(record, attribute)
      return unless record.respond_to?(attribute)

      record.public_send(attribute)
    end

    def self.style_name(record)
      return record.beer_style&.name if record.respond_to?(:beer_style)
      return record.wine_style&.name if record.respond_to?(:wine_style)

      nil
    end

    def self.maker_name(record)
      return unless record.respond_to?(:maker)

      record.maker&.name
    end

    def self.ingredient_names(record)
      return [] unless record.is_a?(Dish)

      record.foods.map(&:name)
    end
  end
end
