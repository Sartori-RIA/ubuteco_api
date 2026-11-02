# frozen_string_literal: true

module Api
  module V1
    module Platform
      class AiUsageController < BaseController
        def index
          @from, @to = parsed_range
          @items = Ai::UsageReport.call(from: @from, to: @to)
        rescue ArgumentError
          render_usage_range_error
        end

        private

        def parsed_range
          from = parse_date(params[:from], default: 6.days.ago.to_date)
          to = parse_date(params[:to], default: Time.zone.today)
          raise ArgumentError if from > to

          [from, to]
        end

        def parse_date(value, default:)
          return default if value.blank?

          Date.iso8601(value)
        end

        def render_usage_range_error
          render_api_errors(
            [{ code: 'validation_error', field: 'from', message: I18n.t('api.errors.ai_usage_range') }],
            status: :unprocessable_content
          )
        end
      end
    end
  end
end
