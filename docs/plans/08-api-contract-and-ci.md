# Plan: API contract & CI/CD

**Status:** completed  
**Project:** ubuteco_api (+ monorepo CI for React)  
**Companion:** [ubuteco-react — testing](../../../ubuteco-react/docs/plans/05-testing.md)  
**Priority:** P2  
**Estimated effort:** 1 sprint

---

## Goal

Single source of truth for the REST API (OpenAPI), automated CI on every push, and a staging topology that matches production (Postgres, Redis, OpenSearch, AnyCable).

---

## Current state

- **Canonical OpenAPI:** `swagger/v1/swagger.yaml` (rswag); `docs/swagger.yaml` synced via `rake openapi:sync_docs`.
- **CI drift check:** `rake openapi:drift_check` in GHA and `bin/ci`.
- **GHA API:** RSpec, RuboCop, Brakeman, bundler-audit, Postgres, Redis, OpenSearch.
- **GHA React:** test, eslint, build (`NEXT_PUBLIC_API_URL`).
- Travis retired; `config/ci.rb` runs RSpec + OpenAPI drift.
- **Release:** [release-process.md](../release-process.md); GitHub Pages on release ([pages.yml](../../.github/workflows/pages.yml)).
- **Rswag:** inventory + platform routes documented.

**Parallel tests:** single-worker RSpec (~4 min in CI); `parallel_tests` not added — revisit if runtime exceeds 10 min.

---

## Phase 1 — OpenAPI as source of truth

- [x] Decide: **rswag-generated** spec is canonical (`swagger/v1/swagger.yaml`)
- [x] CI step: `rake openapi:drift_check` fails if YAML differs after regenerate
- [x] `docs/swagger.yaml` synced from canonical via `rake openapi:sync_docs`
- [x] Publish to GitHub Pages on release (`.github/workflows/pages.yml`)

---

## Phase 2 — GitHub Actions (API)

- [x] Workflow: `bundle install`, `db:prepare`, `rspec`, `rubocop`, `brakeman`, `bundler-audit`
- [x] Services: Postgres, Redis, OpenSearch
- [x] Parallel tests — **N/A** (suite fast; documented above)
- [x] Badge in README

---

## Phase 3 — GitHub Actions (React)

- [x] Workflow: `npm ci`, `eslint`, `next build`, tests
- [x] Env: `NEXT_PUBLIC_API_URL` for build

---

## Phase 4 — Staging environment

- [x] Document env vars — [deploy-runbook.md](../deploy-runbook.md)
- [x] Docker Compose full stack in `docker-compose.yml`
- [x] Migrations + `searchkick:reindex` on deploy checklist (runbook)

---

## Phase 5 — Release process

- [x] Deploy runbook covers migrations, reindex, smoke test, rollback
- [x] Tag → deploy API → deploy front → cable smoke — [release-process.md](../release-process.md)

---

## Definition of done

- [x] Travis retired; GHA green on main
- [x] OpenAPI drift caught in CI
- [x] Staging deploy doc exists
- [x] React eslint in CI
- [x] rswag coverage for inventory/platform routes

---

## References

- `spec/swagger_helper.rb`, `swagger/v1/swagger.yaml`, `lib/tasks/openapi.rake`
- `config/ci.rb`, `.github/workflows/ci.yml`, `.github/workflows/pages.yml`
- `docs/release-process.md`
