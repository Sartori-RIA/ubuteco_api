# frozen_string_literal: true

module Catalog
  module Intake
    class LabelExtractor
      include Inventory::Intake::JsonOutput

      TYPES = {
        'beer' => { style: BeerStyle, style_key: :beer_style_id },
        'wine' => { style: WineStyle, style_key: :wine_style_id }
      }.freeze
      PROMPT = Rails.root.join('app/prompts/intake/label.md.erb')

      def self.call(organization:, user:, bytes:, media_type:, product_type:)
        new(organization:, user:, bytes:, media_type:, product_type:).call
      end

      def initialize(organization:, user:, bytes:, media_type:, product_type:)
        raise ArgumentError, 'unknown product type' unless TYPES.key?(product_type)

        @organization = organization
        @user = user
        @bytes = bytes
        @media_type = media_type
        @product_type = product_type
      end

      def call
        raw = parsed
        maker = match_maker(raw['maker'])
        style = match_style(raw['style'])
        warnings = []
        warnings << 'unknown_maker' if raw['maker'].present? && maker.nil?
        warnings << 'unknown_style' if raw['style'].present? && style.nil?
        {
          draft: draft_for(raw, maker, style),
          confidence: warnings.empty? ? 'high' : 'low',
          warnings:
        }
      end

      private

      attr_reader :organization, :user, :bytes, :media_type, :product_type

      def parsed
        result = Ai::Client.complete(
          feature: Ai::Feature::PRODUCT_INTAKE,
          tier: :smart,
          system: prompt,
          messages: [{ role: 'user', content: content }],
          organization:,
          user:
        )
        value = parse_json(result.text)
        raise Ai::InvalidOutputError unless value.is_a?(Hash) && value['name'].is_a?(String) && value['name'].present?

        value
      end

      def draft_for(raw, maker, style)
        {
          name: raw['name'],
          description: raw['description'].to_s,
          abv: number_or_nil(raw['abv']),
          maker_name: raw['maker'].to_s,
          maker_id: maker&.id,
          style_name: raw['style'].to_s
        }.merge(type_fields(raw, style))
      end

      def type_fields(raw, style)
        if product_type == 'beer'
          { ibu: number_or_nil(raw['ibu']), beer_style_id: style&.id }
        else
          { grapes: raw['grapes'].to_s, vintage_wine: integer_or_nil(raw['vintage']), wine_style_id: style&.id }
        end
      end

      def match_maker(name)
        return if name.blank?

        Maker.where(organization_id: organization.id).where('LOWER(name) = ?', name.to_s.strip.downcase).first
      end

      def match_style(name)
        return if name.blank?

        TYPES.fetch(product_type)[:style].where('LOWER(name) = ?', name.to_s.strip.downcase).first
      end

      def number_or_nil(value)
        return if value.nil?

        raise Ai::InvalidOutputError unless value.is_a?(Numeric)

        value
      end

      def integer_or_nil(value)
        return if value.nil?

        raise Ai::InvalidOutputError unless value.is_a?(Integer)

        value
      end

      def content
        [
          { type: 'image', source: { type: 'base64', media_type:, data: Base64.strict_encode64(bytes) } },
          { type: 'text', text: 'Extract the label.' }
        ]
      end

      def prompt
        ERB.new(PROMPT.read).result_with_hash(product_type:, locale: I18n.locale.to_s)
      end
    end
  end
end
