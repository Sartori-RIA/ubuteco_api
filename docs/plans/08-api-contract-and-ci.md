# Plan: API contract & CI/CD

**Status:** not started  
**Project:** ubuteco_api (+ monorepo CI for React)  
**Companion:** [ubuteco-react — testing](../../../ubuteco-react/docs/plans/05-testing.md)  
**Priority:** P2  
**Estimated effort:** 1 sprint

---

## Goal

Single source of truth for the REST API (OpenAPI), automated CI on every push, and a staging topology that matches production (Postgres, Redis, OpenSearch, AnyCable).

---

## Current state

- rswag specs generate Swagger; also `swagger/v1/swagger.yaml`, `docs/swagger.yaml` (drift risk).
- `.travis.yml` on API; React has no visible CI workflow.
- Rails runs on host; docker-compose for infra only.
- `config/ci.rb` exists for local CI script.

---

## Phase 1 — OpenAPI as source of truth

- [ ] Decide: **rswag-generated** spec is canonical
- [ ] CI step: run rswag and fail if `swagger/v1/swagger.yaml` not committed / differs
- [ ] Deprecate duplicate `docs/swagger.yaml` or sync via script
- [ ] Publish to GitHub Pages / existing docs site on release

---

## Phase 2 — GitHub Actions (API)

- [ ] Workflow: `bundle install`, `db:prepare`, `rspec`, `rubocop`, `brakeman`, `bundler-audit`
- [ ] Services: Postgres, Redis (optional OpenSearch for search specs)
- [ ] Parallel tests if stable (`parallel:spec`)
- [ ] Badge in README

---

## Phase 3 — GitHub Actions (React)

- [ ] Workflow: `npm ci`, `eslint`, `next build`, tests when [05-testing](./../ubuteco-react/docs/plans/05-testing.md) exists
- [ ] Env: `API_URL` mock for build

---

## Phase 4 — Staging environment

- [ ] Document env vars (see [system architecture](../system-architecture.png))
- [ ] Docker Compose profile or separate compose for API container + anycable-go
- [ ] Migrations + `searchkick:reindex` on deploy checklist

---

## Phase 5 — Release process

- [ ] Tag → deploy API → deploy front → smoke test (login, order, kitchen cable)
- [ ] Rollback notes

---

## Definition of done

- [ ] Travis retired or redundant; GHA green on main
- [ ] OpenAPI drift caught in CI
- [ ] Staging deploy doc exists

---

## References

- `spec/swagger_helper.rb`, `swagger/v1/swagger.yaml`
- `config/ci.rb`, `.travis.yml`
