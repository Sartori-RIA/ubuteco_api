# Plan: OpenSearch / Searchkick operations

**Status:** completed  
**Project:** ubuteco_api  
**Branch:** `feature/search-operations`  
**GitHub:** *(open)*

---

## Goal

Reliable full-text search in dev and prod: scoped reindexing, dedicated queue, tenant-safe indexing, and a runbook when OpenSearch is down.

---

## Current state

- Searchkick on User, Order, Organization, Beer, Wine, Drink, Food, Dish, Maker (`callbacks: :async`).
- Async indexing via Sidekiq **`searchkick`** queue; no org-wide reindex on every model commit.
- `ReindexJob` — single-record or org-scoped batch only; full-class via guarded rake task.
- `ImmediateSearchkickIndexing` — sync reindex on catalog product **create**.
- Active Job adapter `:sidekiq` in development and production.
- Search reads via `SearchkickAuthorizable` + CanCanCan; OpenSearch down → **503** `search_unavailable`.
- Runbook: [search-operations-runbook.md](../search-operations-runbook.md).

---

## Phase 1 — Sidekiq queue

- [x] Add `searchkick` queue in `config/sidekiq.yml`
- [x] Configure Searchkick to use `searchkick` queue (`config/initializers/searchkick.rb`)
- [x] Document worker command: `bundle exec sidekiq -C config/sidekiq.yml` (README, dev-setup)

---

## Phase 2 — Scoped reindex job

- [x] `ReindexJob` accepts `organization_id` and scopes via `reindex_for_organization`
- [x] Removed `OrganizationReindexable` org-wide `after_commit` — rely on Searchkick `:async` per record
- [x] `ImmediateSearchkickIndexing` on create for catalog products (sync `reindex(refresh: true)`)
- [x] `ReindexJob` single-record path (`record_id`) for maintenance enqueue
- [x] Full-class reindex: `ALLOW_FULL_SEARCH_REINDEX=1 bin/rails searchkick:reindex:all` only

---

## Phase 3 — Tenant in index

- [x] Audit every `search_data` includes `organization_id` (catalog products)
- [x] Verify `pagy_search_authorized` always merges org filter
- [x] Cross-tenant search spec — `spec/security/cross_tenant/search_spec.rb`

---

## Phase 4 — Operations runbook

- [x] README: start OpenSearch, verify `curl localhost:9200`
- [x] Rake tasks: `searchkick:reindex:all`, `searchkick:reindex:model[]`, `searchkick:reindex:organization[]`
- [x] OpenSearch unavailable → 503 `search_unavailable` (no silent empty results)

---

## Phase 5 — Production

- [x] `OPENSEARCH_URL` via env (`config/initializers/searchkick.rb`, `.env-example`)
- [x] Security plugin documented for prod (dev compose stays open — runbook)
- [x] Index prefix per environment (`SEARCHKICK_INDEX_PREFIX`)

---

## Definition of done

- [x] Async reindex does not rebuild entire DB on every beer update
- [x] `searchkick` queue in Sidekiq
- [x] Runbook in [search-operations-runbook.md](../search-operations-runbook.md)
- [x] Tenant-safe search tests

---

## References

- `app/sidekiq/reindex_job.rb`
- `app/services/searchkick_reindex.rb`
- `lib/tasks/searchkick_reindex.rake`
- `app/controllers/concerns/searchkick_authorizable.rb`
