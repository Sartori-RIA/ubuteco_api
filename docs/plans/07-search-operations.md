# Plan: OpenSearch / Searchkick operations

**Status:** in progress  
**Project:** ubuteco_api  
**Branch:** `feature/search-operations`  
**GitHub:** *(open)*

---

## Goal

Reliable full-text search in dev and prod: scoped reindexing, dedicated queue, tenant-safe indexing, and a runbook when OpenSearch is down.

---

## Current state

- Searchkick on User, Order, Organization, Beer, Wine, Drink, Food, Dish, Maker (`callbacks: :async`).
- `ReindexJob` accepts `organization_id` and calls `reindex_for_organization` when present (`OrganizationScoped`).
- `OrganizationReindexable` enqueues org-scoped reindex on commit; `ImmediateSearchkickIndexing` on `Product` subclasses reindexes on create (sync, for fresh search).
- Sidekiq queues: **`searchkick`**, `default`, `mailers` (`config/sidekiq.yml`); Searchkick ActiveJob + `ReindexJob` use `searchkick` queue.
- Active Job adapter: `:sidekiq` in development and production.
- OpenSearch: 2-node cluster in docker-compose; Rails uses `localhost:9200`.
- Search reads via `SearchkickAuthorizable` + CanCanCan.

---

## Phase 1 — Sidekiq queue

- [x] Add `searchkick` queue in `config/sidekiq.yml`
- [x] Configure Searchkick to use `searchkick` queue (`config/initializers/searchkick.rb`)
- [x] Document worker command: `bundle exec sidekiq -C config/sidekiq.yml` (README, dev-setup)

---

## Phase 2 — Scoped reindex job

- [x] `ReindexJob` accepts `organization_id` and scopes via `reindex_for_organization`
- [x] `OrganizationReindexable` enqueues with org id (not full-class blind reindex by default path)
- [x] `ImmediateSearchkickIndexing` on create for catalog products (sync `reindex(refresh: true)`)
- [ ] Enqueue single-record reindex `{ model, id }` on update (today still org-wide batch on commit)
- [ ] Full-class reindex: admin-only rake task only

---

## Phase 3 — Tenant in index

- [x] Audit every `search_data` includes `organization_id` (catalog products)
- [x] Verify `pagy_search_authorized` always merges org filter
- [x] Cross-tenant search spec (user A query never returns org B hit) — `spec/security/cross_tenant/search_spec.rb`

---

## Phase 4 — Operations runbook

- [~] **OpenSearch / README** — verify `curl localhost:9200` documented (README); full runbook → Phase 4 below
- [ ] Rake tasks: `searchkick:reindex:all` (staging), per-model, per-org
- [ ] Behavior when OpenSearch unavailable: graceful degradation vs 503 (decide + implement)

---

## Phase 5 — Production

- [ ] `OPENSEARCH_URL` / credentials via env
- [ ] Security plugin enabled in prod (unlike dev compose)
- [ ] Index prefix per environment

---

## Definition of done

- [ ] Async reindex does not rebuild entire DB on every beer update
- [x] `searchkick` queue in Sidekiq
- [ ] Runbook in README or this plan
- [x] Tenant-safe search tests

---

## References

- `app/sidekiq/reindex_job.rb`
- `app/controllers/concerns/searchkick_authorizable.rb`
