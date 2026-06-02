# Plan: OpenSearch / Searchkick operations

**Status:** in progress  
**Project:** ubuteco_api  
**Branch:** partial work on `master` / `feature/locale-and-currency`

---

## Goal

Reliable full-text search in dev and prod: scoped reindexing, dedicated queue, tenant-safe indexing, and a runbook when OpenSearch is down.

---

## Current state

- Searchkick on User, Order, Organization, Beer, Wine, Drink, Food, Dish, Maker (`callbacks: :async`).
- `ReindexJob` accepts `organization_id` and calls `reindex_for_organization` when present (`OrganizationScoped`).
- `OrganizationReindexable` enqueues org-scoped reindex on commit; `ImmediateSearchkickIndexing` on `Product` subclasses reindexes on create (sync, for fresh search).
- Sidekiq queues: `default`, `mailers` only — **no dedicated `searchkick` queue yet**.
- OpenSearch: 2-node cluster in docker-compose; Rails uses `localhost:9200`.
- Search reads via `SearchkickAuthorizable` + CanCanCan.

---

## Phase 1 — Sidekiq queue

- [ ] Add `searchkick` queue in `config/sidekiq.yml`
- [ ] Configure Searchkick to use `searchkick` queue
- [ ] Document worker command: `bundle exec sidekiq -q searchkick -q default -q mailers`

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
- [ ] Cross-tenant search spec (user A query never returns org B hit)

---

## Phase 4 — Operations runbook

- [ ] README section: start OpenSearch, verify `curl localhost:9200`
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
- [ ] `searchkick` queue in Sidekiq
- [ ] Runbook in README or this plan
- [ ] Tenant-safe search tests

---

## References

- `app/sidekiq/reindex_job.rb`
- `app/controllers/concerns/searchkick_authorizable.rb`
