# frozen_string_literal: true

module Inventory
  class AdjustStock
    def self.call(product:, adjustment:, reason: nil, user: nil)
      new(product:, adjustment:, reason:, user:).call
    end

    def initialize(product:, adjustment:, reason: nil, user: nil)
      @product = product
      @adjustment = adjustment.to_i
      @reason = reason
      @user = user
    end

    def call
      unless Inventory.stockable?(@product)
        @product.errors.add(:base, I18n.t('inventory.errors.not_stockable'))
        return false
      end

      if @adjustment.zero?
        @product.errors.add(:adjustment, I18n.t('inventory.errors.adjustment_zero'))
        return false
      end

      success = false
      @product.with_lock do
        current = @product.quantity_stock.to_i
        new_stock = current + @adjustment

        if new_stock.negative?
          @product.errors.add(:quantity_stock, I18n.t('inventory.errors.insufficient_stock'))
          return false
        end

        @product.update!(quantity_stock: new_stock)
        Inventory::RecordMovement.call(
          organization: @product.organization,
          product: @product,
          delta: @adjustment,
          reason: @reason,
          user: @user
        )
        success = true
      end

      success
    end
  end
end
