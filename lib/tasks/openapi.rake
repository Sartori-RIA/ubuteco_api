# frozen_string_literal: true

namespace :openapi do
  desc 'Copy canonical OpenAPI spec to docs/swagger.yaml (static Swagger UI site)'
  task sync_docs: :environment do
    canonical = Rails.root.join('swagger/v1/swagger.yaml')
    docs_copy = Rails.root.join('docs/swagger.yaml')
    abort "Missing canonical spec: #{canonical}. Run rake rswag:specs:swaggerize first." unless canonical.exist?

    FileUtils.cp(canonical, docs_copy)
    puts "Synced #{docs_copy} from #{canonical}"
  end

  desc 'Regenerate OpenAPI from rswag and sync docs/swagger.yaml'
  task refresh: ['rswag:specs:swaggerize', 'openapi:sync_docs']

  desc 'Regenerate OpenAPI and fail if committed artifacts differ (CI drift check)'
  task drift_check: :refresh do
    unless system('git diff --quiet -- swagger/v1/swagger.yaml docs/swagger.yaml')
      diff = `git diff --name-only -- swagger/v1/swagger.yaml docs/swagger.yaml`.strip
      abort <<~MSG
        OpenAPI drift detected. Regenerate and commit:
          bundle exec rake openapi:refresh
        Changed files:
          #{diff.presence || 'swagger/v1/swagger.yaml and/or docs/swagger.yaml'}
      MSG
    end

    puts 'OpenAPI artifacts match rswag output.'
  end
end
