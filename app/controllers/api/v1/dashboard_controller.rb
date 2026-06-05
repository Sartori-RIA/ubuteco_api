# frozen_string_literal: true

module Api
  module V1
    class DashboardController < ApplicationController
      def summary
        authorize! :read, :dashboard
        organization = current_organization
        return if organization.blank?

        @summary = cached_payload(organization, :summary) do
          ::Organizations::Dashboard::Summary.call(
            org: organization,
            from: params.require(:from),
            to: params.require(:to)
          )
        end
        render :summary
      rescue ::Organizations::Dashboard::RangeParser::InvalidRange => e
        render_api_errors([{ code: "invalid_range", message: e.message }])
      end

      def series
        authorize! :read, :dashboard
        organization = current_organization
        return if organization.blank?

        grain = params.fetch(:grain, 'day')
        metric = params.fetch(:metric, 'revenue')
        @series = cached_payload(organization, :series, grain:, metric:) do
          ::Organizations::Dashboard::Series.call(
            org: organization,
            from: params.require(:from),
            to: params.require(:to),
            grain:,
            metric:
          )
        end
        render :series
      rescue ::Organizations::Dashboard::RangeParser::InvalidRange => e
        render_api_errors([{ code: "invalid_range", message: e.message }])
      end

      def kitchen
        authorize! :read, :dashboard
        organization = current_organization
        return if organization.blank?

        @kitchen = cached_payload(organization, :kitchen) do
          ::Organizations::Dashboard::Kitchen.call(
            org: organization,
            from: params.require(:from),
            to: params.require(:to)
          )
        end
        render :kitchen
      rescue ::Organizations::Dashboard::RangeParser::InvalidRange => e
        render_api_errors([{ code: "invalid_range", message: e.message }])
      end

      private

      def current_organization
        organization = Current.organization
        return organization if organization.present?

        head :forbidden
        nil
      end

      def cached_payload(organization, kind, **extra_params, &block)
        ::Organizations::Dashboard::Cache.fetch(
          org: organization,
          kind:,
          from: params.require(:from),
          to: params.require(:to),
          **extra_params,
          &block
        )
      end
    end
  end
end
