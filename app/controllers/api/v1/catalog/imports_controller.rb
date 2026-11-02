# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class ImportsController < ApplicationController
        def index
          authorize_admin!
          imports = current_user.organization.catalog_imports.newest_first
          render json: imports.map(&:as_status_json)
        end

        def show
          authorize_admin!
          render json: catalog_import.as_status_json(include_log: true)
        end

        def create
          authorize_admin!
          ::Catalog::CsvImport::FileGuard.call(params[:file])
          table = ::Catalog::CsvImport::Table.parse(params[:file], product_type: params[:product_type])
          authorize! :create, ::Catalog::CsvImport::Columns.model_for(params[:product_type])
          record = enqueue(table)
          render json: accepted_payload(record), status: :accepted
        rescue ::Catalog::CsvImport::InvalidFile => e
          render_api_errors([{ code: 'invalid_csv', message: e.message }])
        rescue ::Catalog::CsvImport::Busy => e
          render_busy(e.import)
        end

        def template
          authorize_admin!
          type = params[:product_type].to_s
          raise ::Catalog::CsvImport::InvalidFile, :unknown_type unless CatalogImport::PRODUCT_TYPES.include?(type)

          send_data(
            ::Catalog::CsvImport::Columns.template_csv(type),
            filename: "#{type}.csv",
            type: 'text/csv; charset=utf-8'
          )
        rescue ::Catalog::CsvImport::InvalidFile => e
          render_api_errors([{ code: 'invalid_csv', message: e.message }])
        end

        private

        def authorize_admin!
          authorize! :create, Beer
        end

        def catalog_import
          @catalog_import ||= current_user.organization.catalog_imports.find(params[:id])
        end

        def enqueue(table)
          record = nil
          current_user.organization.with_lock do
            existing = current_user.organization.catalog_imports.active.first
            raise ::Catalog::CsvImport::Busy, existing if existing

            record = build_import(table)
          end
          ::Catalog::CsvImportJob.perform_async(record.id)
          record
        end

        def build_import(table)
          record = current_user.organization.catalog_imports.create!(
            user: current_user,
            product_type: params[:product_type],
            status: 'queued',
            total_rows: table.rows.size,
            enqueued_at: Time.current
          )
          record.file.attach(io: StringIO.new(table.source), filename: 'import.csv', content_type: 'text/csv')
          record
        end

        def accepted_payload(record)
          { id: record.id, status: record.status, estimated_start_at: record.estimated_start_at }
        end

        def render_busy(import)
          render json: {
            id: import.id,
            status: import.status,
            errors: [{ code: 'import_in_progress', message: I18n.t('api.errors.import_in_progress') }]
          }, status: :conflict
        end
      end
    end
  end
end
