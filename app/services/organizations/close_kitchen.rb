# frozen_string_literal: true

module Organizations
  class CloseKitchen
    def self.call(organization:)
      new(organization:).call
    end

    def initialize(organization:)
      @organization = organization
    end

    def call
      return 0 unless @organization.closed?

      closed_count = @organization.orders.open.update_all(
        status: Order.statuses[:closed],
        updated_at: Time.current
      )

      Rails.logger.info(
        "[Kitchen] organization=#{@organization.id} operational_status=closed auto_closed_orders=#{closed_count}"
      )

      closed_count
    end
  end
end
