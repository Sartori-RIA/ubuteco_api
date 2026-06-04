# frozen_string_literal: true

module Kitchen
  class BroadcastOrderItem
    def self.call(order_item:, action:)
      new(order_item:, action:).call
    end

    def initialize(order_item:, action:)
      @order_item = order_item
      @action = action
    end

    def call
      unless broadcastable?
        log_skipped
        return false
      end

      record = OrderItem.includes(:item, order: :table).find(@order_item.id)
      payload = ApplicationController.render(
        template: "api/v1/kitchens/_kitchen",
        locals: { kitchen: record }
      )
      message = {
        obj: JSON.parse(payload),
        action: @action
      }

      Rails.logger.info(
        "[KitchenCable] broadcast #{@action} order_item=#{record.id} org=#{record.order.organization_id}"
      )
      KitchenCableBroadcaster.deliver(organization_id: record.order.organization_id, message:)

      true
    end

    private

    def broadcastable?
      @order_item.dish? && @order_item.order.open? && @order_item.order.organization.reload.open?
    end

    def log_skipped
      org = @order_item.order.organization
      Rails.logger.info(
        "[KitchenCable] skipped broadcast #{@action} order_item=#{@order_item.id} " \
        "order_open=#{@order_item.order.open?} org_open=#{org.open?} org_id=#{org.id}"
      )
    end
  end
end
