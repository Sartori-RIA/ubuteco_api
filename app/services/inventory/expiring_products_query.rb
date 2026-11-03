# frozen_string_literal: true

module Inventory
  class ExpiringProductsQuery
    def self.call(organization:, warning_days: Inventory.expiry_warning_days, include_expired: true)
      new(organization:, warning_days:, include_expired:).call
    end

    def initialize(organization:, warning_days:, include_expired:)
      @organization = organization
      @warning_days = warning_days
      @include_expired = include_expired
      @zone = Time.find_zone!(organization.timezone.presence || 'UTC')
      @today = Time.current.in_time_zone(@zone).to_date
    end

    def call
      Inventory::EXPIRY_CLASSES.flat_map { |klass| items_for(klass) }
                               .sort_by { |item| [item.fetch(:expiry_on), item.fetch(:name)] }
                               .map { |item| item.except(:expiry_on) }
    end

    private

    def items_for(klass)
      klass.where(organization_id: @organization.id)
           .where.not(valid_until: nil)
           .filter_map { |record| serialize(record) }
    end

    def serialize(record)
      expiry_on = record.valid_until.in_time_zone(@zone).to_date
      days_remaining = (expiry_on - @today).to_i
      status = days_remaining.negative? ? 'expired' : 'expiring'
      return if status == 'expired' && !@include_expired
      return if status == 'expiring' && days_remaining > @warning_days

      {
        product_type: record.model_name.route_key,
        id: record.id,
        name: record.name,
        valid_until: record.valid_until.iso8601,
        days_remaining:,
        status:,
        expiry_on:
      }
    end
  end
end
