# Plan: OpenSearch / Searchkick operations

**Status:** not started  
**Project:** ubuteco_api  
**Priority:** P2  
**Depends on:** [01-multi-tenant](./01-multi-tenant.md)  
**Estimated effort:** 0.5–1 sprint

---

## Goal

Reliable full-text search in dev and prod: scoped reindexing, dedicated queue, tenant-safe indexing, and a runbook when OpenSearch is down.

---

## Current state

- Searchkick on User, Order, Organization, Beer, Wine, Drink, Food, Dish, Maker (`callbacks: :async`).
- `ReindexJob` calls `model.reindex` for **entire model class** (all tenants).
- Sidekiq queues: `default`, `mailers` only.
- OpenSearch: 2-node cluster in docker-compose; Rails uses `localhost:9200`.
- Search reads via `SearchkickAuthorizable` + CanCanCan.

---

## Phase 1 — Sidekiq queue

- [ ] Add `searchkick` queue in `config/sidekiq.yml`
- [ ] Configure Searchkick to use `searchkick` queue
- [ ] Document worker command: `bundle exec sidekiq -q searchkick -q default -q mailers`

---

## Phase 2 — Scoped reindex job

- [ ] Replace or extend `ReindexJob`:
  - `perform(model_name, record_id = nil, organization_id = nil)`
  - Single record: `Model.find(id).reindex`
  - Org scope: `Model.where(organization_id:).find_each(&:reindex)`
  - Full class: admin-only rake task, not default callback path
- [ ] Model callbacks enqueue `{ model, id }` not class name only

---

## Phase 3 — Tenant in index

- [ ] Audit every `search_data` includes `organization_id`
- [ ] Verify `pagy_search_authorized` always merges org filter
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
