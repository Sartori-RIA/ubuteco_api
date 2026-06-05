# OpenSearch / Searchkick runbook

Operations guide for **ubuteco_api** search. See also [plan 07](./plans/07-search-operations.md).

## Dev stack

Start OpenSearch (included in full compose):

```bash
docker compose up -d opensearch-node1 opensearch-node2
curl -s http://localhost:9200 | head -c 200
```

Sidekiq must process the **`searchkick`** queue (`config/sidekiq.yml`). Docker Compose starts Sidekiq with that config automatically.

## Index updates

| Trigger | Mechanism |
|---------|-----------|
| Create / update / destroy | Searchkick `callbacks: :async` → Sidekiq `searchkick` queue |
| New catalog product (create) | Additional sync `reindex(refresh: true)` via `ImmediateSearchkickIndexing` |
| Maintenance / staging rebuild | Rake tasks below |

## Rake tasks

```bash
# One model
bin/rails searchkick:reindex:model[Beer]

# All records for one organization
bin/rails searchkick:reindex:organization[ORG_ID]

# Full rebuild (staging/maintenance only)
ALLOW_FULL_SEARCH_REINDEX=1 bin/rails searchkick:reindex:all
```

After deploy migrations that change indexed fields, run the appropriate reindex before traffic.

## Environment variables

| Variable | Purpose |
|----------|---------|
| `OPENSEARCH_URL` | Cluster URL (default `http://localhost:9200`; compose uses `http://opensearch-node1:9200`) |
| `SEARCHKICK_INDEX_PREFIX` | Optional index prefix per environment (e.g. `staging`, `production`) |
| `ALLOW_FULL_SEARCH_REINDEX` | Must be `1` for `searchkick:reindex:all` |

Production credentials: embed user/password in `OPENSEARCH_URL` or extend `Searchkick.client_options` in `config/initializers/searchkick.rb`.

## Production OpenSearch

- Use a managed cluster URL in `OPENSEARCH_URL` (HTTPS).
- Enable the **Security plugin** (dev docker-compose disables it for simplicity).
- Set `SEARCHKICK_INDEX_PREFIX` so staging and production never share indices.
- Run Sidekiq with `-C config/sidekiq.yml` and enough workers on the `searchkick` queue.

## When OpenSearch is down

Search **read** endpoints return **503** with:

```json
{ "errors": [{ "code": "search_unavailable", "message": "Search is temporarily unavailable" }] }
```

Writes to PostgreSQL continue; Sidekiq retries indexing when OpenSearch recovers.

## Troubleshooting

1. **Empty search results after create** — confirm Sidekiq is running and listening to `searchkick`; check Redis queue depth.
2. **Stale results** — run `searchkick:reindex:organization[ORG_ID]` or model-specific reindex.
3. **CI / tests** — specs use `Searchkick.callbacks(:inline)`; see `spec/support/searchkick.rb`.
