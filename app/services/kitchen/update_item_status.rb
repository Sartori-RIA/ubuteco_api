# frozen_string_literal: true

module Kitchen
  class UpdateItemStatus
    class KitchenClosed < StandardError; end

    def self.call(order_item:, status:, organization:)
      new(order_item:, status:, organization:).call
    end

    def initialize(order_item:, status:, organization:)
      @order_item = order_item
      @status = status
      @organization = organization
    end

    def call
      raise KitchenClosed if @organization.closed?
      return @order_item if @status.blank?

      @order_item.update(status: @status)
      @order_item
    end
  end
end
