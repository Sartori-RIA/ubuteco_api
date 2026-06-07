# Plan: API contract & CI/CD

**Status:** in progress  
**Project:** ubuteco_api (+ monorepo CI for React)  
**Companion:** [ubuteco-react — testing](../../../ubuteco-react/docs/plans/05-testing.md)  
**Priority:** P2  
**Estimated effort:** 1 sprint

---

## Goal

Single source of truth for the REST API (OpenAPI), automated CI on every push, and a staging topology that matches production (Postgres, Redis, OpenSearch, AnyCable).

---

## Current state

- **Canonical OpenAPI:** `swagger/v1/swagger.yaml` (rswag-generated); `docs/swagger.yaml` synced via `rake openapi:sync_docs`.
- **CI drift check:** `rake openapi:drift_check` in GHA and `bin/ci`.
- GHA on API: RSpec, RuboCop, Brakeman, bundler-audit, Postgres, OpenSearch.
- GHA on React: test + build (eslint deferred — 5 pre-existing lint errors).
- Travis retired; `config/ci.rb` runs RSpec + OpenAPI drift.

---

## Phase 1 — OpenAPI as source of truth

- [x] Decide: **rswag-generated** spec is canonical (`swagger/v1/swagger.yaml`)
- [x] CI step: `rake openapi:drift_check` fails if YAML differs after regenerate
- [x] `docs/swagger.yaml` synced from canonical via `rake openapi:sync_docs`
- [ ] Publish to GitHub Pages / existing docs site on release

---

## Phase 2 — GitHub Actions (API)

- [x] Workflow: `bundle install`, `db:prepare`, `rspec`, `rubocop`, `brakeman`, `bundler-audit`
- [x] Services: Postgres, OpenSearch (optional Redis — health returns skipped without `REDIS_URL`)
- [ ] Parallel tests if stable (`parallel:spec`)
- [x] Badge in README

---

## Phase 3 — GitHub Actions (React)

- [x] Workflow: `npm ci`, `next build`, tests
- [ ] `eslint` in CI (blocked: fix 5 `react-hooks/set-state-in-effect` errors first)
- [x] Env: `NEXT_PUBLIC_API_URL` for build

---

## Phase 4 — Staging environment

- [x] Document env vars — see [deploy-runbook.md](../deploy-runbook.md)
- [x] Docker Compose full stack in `docker-compose.yml`
- [x] Migrations + `searchkick:reindex` on deploy checklist (runbook)

---

## Phase 5 — Release process

- [x] Deploy runbook covers migrations, reindex, smoke test, rollback
- [ ] Tag → deploy API → deploy front → cable smoke as single documented release flow

---

## Definition of done

- [x] Travis retired; GHA green on main
- [x] OpenAPI drift caught in CI
- [x] Staging deploy doc exists (`deploy-runbook.md`)
- [ ] React eslint in CI
- [ ] rswag coverage for inventory/platform routes (optional follow-up)

---

## References

- `spec/swagger_helper.rb`, `swagger/v1/swagger.yaml`, `lib/tasks/openapi.rake`
- `config/ci.rb`, `.github/workflows/ci.yml`
