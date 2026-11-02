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

      def brief
        authorize! :read, :dashboard
        organization = current_organization
        return if organization.blank?

        key = brief_cache_key(organization)
        Rails.cache.delete(key) if refresh? && allow_refresh?(organization)
        render json: Rails.cache.fetch(key, expires_in: 30.minutes) {
          ::Organizations::DailyBrief::Compose.call(organization:, user: current_user)
        }
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

      def refresh?
        ActiveModel::Type::Boolean.new.cast(params[:refresh])
      end

      def allow_refresh?(organization)
        key = "dashboard:org:#{organization.id}:brief:refresh"
        return false if Rails.cache.exist?(key)

        Rails.cache.write(key, true, expires_in: 60.seconds)
        true
      end

      def brief_cache_key(organization)
        zone = Time.find_zone!(organization.timezone.presence || 'UTC')
        date = Time.current.in_time_zone(zone).to_date
        "dashboard:org:#{organization.id}:brief:#{date.iso8601}"
      end

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
