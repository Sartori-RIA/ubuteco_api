# frozen_string_literal: true

module Inventory
  class RecordMovement
    def self.call(organization:, product:, delta:, reason: nil, user: nil, order_item: nil)
      new(organization:, product:, delta:, reason:, user:, order_item:).call
    end

    def initialize(organization:, product:, delta:, reason: nil, user: nil, order_item: nil)
      @organization = organization
      @product = product
      @delta = delta.to_i
      @reason = reason
      @user = user
      @order_item = order_item
    end

    def call
      return nil unless Inventory.stockable?(@product)
      return nil if @delta.zero?

      StockMovement.create!(
        organization: @organization,
        product: @product,
        delta: @delta,
        reason: @reason.presence,
        user: @user,
        order_item: @order_item
      )
    end
  end
end
