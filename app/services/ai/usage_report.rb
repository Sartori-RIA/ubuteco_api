# frozen_string_literal: true

module Ai
  class UsageReport
    Row = Data.define(
      :organization_id, :organization_name, :feature, :day,
      :calls, :input_tokens, :output_tokens, :failed_calls
    )

    def self.call(from:, to:)
      new(from:, to:).call
    end

    def initialize(from:, to:)
      @from = from
      @to = to
    end

    def call
      names = organization_names
      grouped.map { |row| build_row(row, names) }
    end

    private

    attr_reader :from, :to

    def grouped
      AiUsageEvent
        .where(created_at: from.beginning_of_day..to.end_of_day)
        .group(:organization_id, :feature, day_sql)
        .order(Arel.sql('DATE(ai_usage_events.created_at) DESC'))
        .pluck(
          :organization_id,
          :feature,
          day_sql,
          Arel.sql('COUNT(*)'),
          Arel.sql('COALESCE(SUM(input_tokens), 0)'),
          Arel.sql('COALESCE(SUM(output_tokens), 0)'),
          Arel.sql("COALESCE(SUM(CASE WHEN status <> 'ok' THEN 1 ELSE 0 END), 0)")
        )
    end

    def day_sql
      Arel.sql('DATE(ai_usage_events.created_at)')
    end

    def organization_names
      Organization.where(id: grouped_organization_ids).pluck(:id, :name).to_h
    end

    def grouped_organization_ids
      AiUsageEvent.where(created_at: from.beginning_of_day..to.end_of_day).distinct.pluck(:organization_id)
    end

    def build_row(row, names)
      organization_id, feature, day, calls, input_tokens, output_tokens, failed_calls = row
      Row.new(
        organization_id:,
        organization_name: names[organization_id],
        feature:,
        day: coerce_day(day),
        calls:,
        input_tokens:,
        output_tokens:,
        failed_calls:
      )
    end

    def coerce_day(day)
      day.is_a?(Date) ? day : Date.parse(day.to_s)
    end
  end
end
