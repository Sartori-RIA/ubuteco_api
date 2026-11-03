# frozen_string_literal: true

module Inventory
  class RestockExplainer
    LIMIT = 5

    def self.call(organization:, items:, cover_days:, window_days:, user: nil)
      new(organization:, items:, cover_days:, window_days:, user:).call
    end

    def initialize(organization:, items:, cover_days:, window_days:, user:)
      @organization = organization
      @items = items
      @cover_days = cover_days
      @window_days = window_days
      @user = user
    end

    def call
      targets = @items.select { |item| item[:confidence] == 'ok' }.first(LIMIT)
      return @items if targets.empty?

      attach(complete(targets))
    rescue Ai::Error, JSON::ParserError
      @items
    end

    private

    def complete(targets)
      Ai::Client.complete(
        feature: Ai::Feature::RESTOCK_EXPLAIN,
        tier: :fast,
        organization: @organization,
        user: @user,
        system: system_prompt,
        messages: [{ role: 'user', content: facts_for(targets).to_json }]
      ).text
    end

    def system_prompt
      locale = @organization.locale.presence || 'pt-BR'
      <<~TEXT.squish
        Reply with a JSON array only. Each object has product_type, id, and explanation.
        explanation is one sentence in #{locale}. Use only numbers present in the input.
        Do not add a quantity that is not in the input.
      TEXT
    end

    def facts_for(targets)
      targets.map do |item|
        item.slice(:product_type, :id, :name, :quantity_stock, :avg_daily, :days_of_cover, :suggested_quantity)
            .merge(cover_days: @cover_days, window_days: @window_days)
      end
    end

    def attach(text)
      rows = JSON.parse(strip_fence(text))
      return @items unless rows.is_a?(Array)

      by_key = rows.index_by { |row| [row['product_type'], row['id']] }
      @items.map do |item|
        sentence = by_key[[item[:product_type], item[:id]]]&.fetch('explanation', nil)
        next item if sentence.blank? || !Ai::NumberGuard.allowed?(sentence, allowed_numbers(item))

        item.merge(explanation: sentence)
      end
    end

    def allowed_numbers(item)
      [
        item[:quantity_stock], item[:avg_daily], item[:days_of_cover], item[:suggested_quantity],
        @cover_days, @window_days
      ]
    end

    def strip_fence(text)
      text.to_s.sub(/\A```(?:json)?\s*/i, '').sub(/\s*```\z/, '')
    end
  end
end
