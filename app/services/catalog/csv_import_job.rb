# frozen_string_literal: true

module Catalog
  class CsvImportJob
    include Sidekiq::Job

    sidekiq_options queue: :imports, retry: 0

    def perform(import_id)
      import = CatalogImport.find_by(id: import_id)
      return if import.nil? || !import.queued?

      process(import)
    end

    private

    def process(import)
      Current.organization = import.organization
      with_organization(import.organization) { run(import) }
    rescue StandardError => e
      import.update!(status: 'failed', error_message: e.message.to_s.truncate(500), finished_at: Time.current)
    ensure
      finish(import)
    end

    def run(import)
      import.update!(status: 'running', started_at: Time.current)
      CsvImport::Runner.new(import).call
      import.update!(status: 'completed', finished_at: Time.current)
    end

    def finish(import)
      CatalogImportMailer.with(import: import.reload).finished.deliver_later
      Rails.logger.info(log_line(import))
      import.file.purge if import.file.attached?
    rescue StandardError => e
      Rails.logger.error("catalog_import_finish import_id=#{import.id} error=#{e.class}")
    ensure
      Current.reset
    end

    def with_organization(organization, &)
      previous = Money.default_currency
      Money.default_currency = Money::Currency.wrap(organization.default_currency)
      I18n.with_locale(organization.locale) { Time.use_zone(organization.timezone, &) }
    ensure
      Money.default_currency = previous
    end

    def log_line(import)
      "catalog_import organization_id=#{import.organization_id} import_id=#{import.id} " \
        "product_type=#{import.product_type} status=#{import.status} " \
        "created_rows=#{import.created_rows} failed_rows=#{import.failed_rows}"
    end
  end
end
