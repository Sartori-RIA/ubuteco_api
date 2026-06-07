# frozen_string_literal: true

module Inventory
  class LowStockQuery
    def self.call(organization_id:, threshold: Inventory.low_stock_threshold)
      new(organization_id:, threshold:).call
    end

    def initialize(organization_id:, threshold:)
      @organization_id = organization_id
      @threshold = threshold
    end

    def call
      Inventory::STOCKABLE_CLASSES.flat_map { |klass| items_for(klass) }
                                  .sort_by { |item| [item[:quantity_stock], item[:name]] }
    end

    private

    def items_for(klass)
      klass.where(organization_id: @organization_id)
           .where(quantity_stock: ..@threshold)
           .map { |record| serialize(record) }
    end

    def serialize(record)
      {
        product_type: record.model_name.route_key,
        id: record.id,
        name: record.name,
        quantity_stock: record.quantity_stock.to_i,
        threshold: @threshold
      }
    end
  end
end
