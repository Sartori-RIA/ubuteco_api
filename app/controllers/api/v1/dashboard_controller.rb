# frozen_string_literal: true

module Api
  module V1
    class DashboardController < ApplicationController
      def summary
        authorize! :read, :dashboard
        organization = Current.organization
        return head :forbidden if organization.blank?

        payload = ::Organizations::Dashboard::Summary.call(
          org: organization,
          from: params.require(:from),
          to: params.require(:to)
        )
        @summary = payload
        render :summary
      rescue ::Organizations::Dashboard::RangeParser::InvalidRange => e
        render json: [e.message], status: :unprocessable_content
      end

      def series
        authorize! :read, :dashboard
        organization = Current.organization
        return head :forbidden if organization.blank?

        payload = ::Organizations::Dashboard::Series.call(
          org: organization,
          from: params.require(:from),
          to: params.require(:to),
          grain: params.fetch(:grain, 'day'),
          metric: params.fetch(:metric, 'revenue')
        )
        @series = payload
        render :series
      rescue ::Organizations::Dashboard::RangeParser::InvalidRange => e
        render json: [e.message], status: :unprocessable_content
      end
    end
  end
end
