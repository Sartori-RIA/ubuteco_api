# Search & OpenSearch

Stable reference for Searchkick full-text search. Plan: [07-search-operations](../plans/07-search-operations.md). Operations: [search-operations-runbook.md](../search-operations-runbook.md).

## Indexed models

Searchkick on (all include `organization_id` in `search_data` where tenant-scoped):

- `User`, `Order`, `Organization`
- Catalog: `Beer`, `Wine`, `Drink`, `Food`, `Dish`, `Maker`

Config: `callbacks: :async` → Sidekiq **`searchkick`** queue (`config/initializers/searchkick.rb`, `config/sidekiq.yml`).

## Read path (controllers)

- Use `pagy_search_authorized(Model)` from `SearchkickAuthorizable` — merges CanCan conditions into OpenSearch `where` filter.
- **Never** run unscoped `Model.search` in org-facing controllers.
- OpenSearch down → `SearchUnavailableError` → **503** `search_unavailable` (no silent empty results).

```ruby
@pagy, @records = pagy_search_authorized(User)
@pagy, @records = pagy_search_authorized(Beer, extra_where: { active: true })
```

## Write path (indexing)

| Trigger | Mechanism |
|---------|-----------|
| Record create/update/destroy | Searchkick async callback → `searchkick` queue |
| New catalog product create | Extra sync `reindex(refresh: true)` via `ImmediateSearchkickIndexing` |
| Maintenance | Rake tasks or `ReindexJob` |

**Do not** add org-wide `after_commit` reindex on every model change — use per-record async indexing.

## ReindexJob (`app/sidekiq/reindex_job.rb`)

| Args | Behaviour |
|------|-----------|
| `model_name`, `record_id` | Single-record reindex |
| `model_name`, `nil`, `organization_id` | Org-scoped batch via `reindex_for_organization` |
| Neither id nor org | **Refused** — use rake with env guard |

Sets `Current.organization` during org-scoped reindex; calls `Current.reset` in `ensure`.

## Rake tasks

```bash
bin/rails searchkick:reindex:model[Beer]
bin/rails searchkick:reindex:organization[ORG_ID]
ALLOW_FULL_SEARCH_REINDEX=1 bin/rails searchkick:reindex:all   # staging/maintenance only
```

## Environment

| Variable | Purpose |
|----------|---------|
| `OPENSEARCH_URL` | Cluster URL |
| `SEARCHKICK_INDEX_PREFIX` | Per-env index prefix (staging vs production) |
| `ALLOW_FULL_SEARCH_REINDEX` | Must be `1` for full reindex |

## Key files

```
app/controllers/concerns/searchkick_authorizable.rb
app/sidekiq/reindex_job.rb
app/services/searchkick_reindex.rb
lib/tasks/searchkick_reindex.rake
spec/support/searchkick.rb
spec/security/cross_tenant/search_spec.rb
```

## Testing

- Specs: `Searchkick.callbacks(:inline)` in `spec/support/searchkick.rb`
- Cross-tenant: `spec/security/cross_tenant/search_spec.rb`
- Unavailable: `spec/requests/search_unavailable_spec.rb`

## AI pitfalls

- Do not search without org filter — always `pagy_search_authorized`.
- Do not trigger full-class reindex in application code.
- Jobs that reindex must set `Current` or pass `organization_id` to `ReindexJob`.
- After changing `search_data` fields, document reindex in plan Manual steps.
