# frozen_string_literal: true

Searchkick.queue_name = :searchkick

# OpenSearch cluster URL (Searchkick reads OPENSEARCH_URL by default).
# Production: use HTTPS + credentials in the URL or via Searchkick.client_options.
Searchkick.client_options = Searchkick.client_options.merge(
  url: ENV.fetch("OPENSEARCH_URL", "http://localhost:9200")
)

if ENV["SEARCHKICK_INDEX_PREFIX"].present?
  Searchkick.index_prefix = ENV.fetch("SEARCHKICK_INDEX_PREFIX")
end
