# Plan: Platform hardening (API)

**Status:** in progress  
**Project:** ubuteco_api  
**GitHub:** [Sartori-RIA/ubuteco_api#39](https://github.com/Sartori-RIA/ubuteco_api/pull/39) (merged) · [#37](https://github.com/Sartori-RIA/ubuteco_api/pull/37) (merged)  
**Branch:** `master` — ongoing work continues on `feature/<slug>`  
**Priority:** Ongoing (parallel to feature plans)  
**Estimated effort:** spread across sprints

---

## Goal

Cross-cutting improvements: security, API consistency, performance, observability, and production readiness. Not a single release — track by subsection.

---

## 1. Security & authorization

- [ ] **IDOR audit** — covered in [01-multi-tenant](./01-multi-tenant.md); re-verify after each new resource
- [x] **rack-attack**: throttle `/auth/sign_in`, `/auth/sign_up`, search endpoints
- [x] **JWT**: document expiry; consider refresh token or denylist on logout — documented in [api-conventions.md](./api-conventions.md) (refresh TBD)
- [x] **CORS**: replace `origins '*'` with env-based allowlist; dev defaults include Next.js ports `:3001`, `:4000`
- [ ] **AnyCable**: explicit `ANYCABLE_ALLOWED_ORIGINS` in prod; rotate `ANYCABLE_SECRET` — env documented; prod config TBD
- [x] **Secrets**: no secrets in repo; credentials/env for JWT, AnyCable, OpenSearch — `.env-example` updated

**Done when:** Brakeman + bundler-audit clean; rate limits in staging.

---

## 2. API design & consistency

- [x] **Error format** standard — `ApiErrorRenderable` + [api-conventions.md](./api-conventions.md)
- [x] Migrate controllers from `render json: model.errors.full_messages` — all `api/v1` controllers use `render_model_errors` / `render_api_errors`
- [~] **Service objects** for multi-step flows — merged from [06-order-lifecycle](./06-order-lifecycle.md):
  - [x] `Orders::AddItem`, `Orders::UpdateItem`, `Orders::RemoveItem`
  - [x] `Kitchen::UpdateItemStatus`, `Organizations::CloseKitchen`
  - [ ] `Orders::RecalculateTotal` (optional extract)
- [x] **State machines** (AASM) for `Order` and `OrderItem` — merged from plan 06
- [ ] **Idempotency-Key** header on `POST` order items / create order (optional Redis store)
- [ ] **Serializers**: evaluate Blueprinter vs Jbuilder consistency

**Done when:** style guide maintained in [api-conventions.md](./api-conventions.md); legacy error arrays fully migrated (#39).

---

## 3. Performance

- [x] **Bullet** in development; fix N+1 on orders#show, kitchens#index (index already `includes`; orders index/show preload associations)
- [ ] **Strict loading** (`strict_loading_by_default` in dev) on hot paths
- [ ] **Searchkick**: scope reindex jobs; avoid full-class `ReindexJob` without org filter — [07-search-operations](./07-search-operations.md) Phase 2
- [ ] **Database**: review composite indexes with [04-organization-dashboard](./04-organization-dashboard.md)
- [ ] **Fragment caching** — low priority for API-only; skip unless HTML partials grow

**Done when:** Bullet warnings zero on main user flows.

---

## 4. Observability

- [~] **Structured logging**: org_id, user_id, request_id in Lograge/JSON logs — `append_info_to_payload` on `ApplicationController` (#39; reads `organization_id` from `current_user` after `Current.reset`); Lograge JSON in prod TBD
- [x] **Health check** `/up`: extend with Redis ping (optional OpenSearch)
- [ ] **Sidekiq**: monitor dead queue; alert on growth
- [ ] **Action Cable / AnyCable**: keep dev transmit logs; reduce noise in prod

**Done when:** single log line per request with tenant context in staging.

---

## 5. Quality & CI

- [x] **Cross-tenant specs** — expanded `access_spec` (tables, beers, orgs, dashboard); search cross-tenant → [07-search-operations](./07-search-operations.md)
- [~] **OpenAPI / rswag** synced with controllers — 422 responses use `errors_response` schema (#39); kitchen `kitchen_closed`, operational_status, dashboard gaps remain
- [ ] **Parallel specs** stable in CI
- [x] **Coverage** — Codecov patch on #39; `spec/requests/platform_hardening_spec.rb`; Bullet initializer excluded in `codecov.yml`
- [x] **Brakeman + bundler-audit** in GitHub Actions
- [x] **CI required checks** documented in README

---

## 6. Production infrastructure

- [ ] **Active Storage** → S3 + CDN URLs
- [~] **Sidekiq queues**: `default`, `searchkick`, `mailers` with concurrency config — `searchkick` queue live (#07 Phase 1)
- [ ] **OpenSearch**: managed cluster URL via env; security plugin in prod
- [ ] **AnyCable**: separate `anycable-go` service; not `allowed_origins *`
- [x] **Deploy runbook** (draft) — [docs/deploy-runbook.md](../deploy-runbook.md); link from README (#39)

**Done when:** staging environment matches production topology.

---

## 7. Real-time (kitchen) maintenance

- [ ] Keep `KitchenCableBroadcaster` broadcast-only under AnyCable
- [ ] Integration spec: broadcast reaches channel (optional system test with AnyCable)
- [ ] Document dev stack in [README](../README.md#system-architecture) — Docker-first Quick Start updated; diagram PNG still shows host Rails (optional follow-up)

---

## 8. Docker — API application

**Current state:** `docker-compose.yml` runs **infra + API + Sidekiq** (`ubuteco_api`, `ubuteco_sidekiq`, Postgres, Redis 7, OpenSearch, AnyCable-go, Mailcatcher). Host-Rails flow remains optional — see [dev-setup.md](../dev-setup.md).

- [x] **`Dockerfile`** — Ruby 4.0.1-slim image; Bundler install; Puma as default CMD
- [x] **Compose services** — `api` (Puma) and `sidekiq`; internal network names for `db`, `cache`, OpenSearch, AnyCable
- [x] **Environment** — compose env for container dev (`DB_HOST=db`, `REDIS_URL`, `OPENSEARCH_URL`, `ANYCABLE_RPC_HOST`, JWT/secrets)
- [x] **One-command dev** — `docker compose up -d --build` starts infra + API
- [x] **README / dev-setup** — Docker-first Quick Start; seed/populate documented
- [x] **Dev vs host transition** — infra-only: start named services without `api`/`sidekiq` (see dev-setup)
- [~] **Staging / deploy path** — same image in staging; [deploy-runbook.md](../deploy-runbook.md) draft

**Done when:** staging can run the API container with the same compose topology as production.

---

## Suggested order (within hardening)

1. Security (CORS, rate limit) — quick wins  
2. Error format + one service object pilot  
3. Bullet / N+1  
4. Logging  
5. Dockerize API (dev + staging parity with existing compose)  
6. Production infra before go-live  

---

## Progress log

| Date | PR | Delivered |
|------|-----|-----------|
| 2026-05 | [#37](https://github.com/Sartori-RIA/ubuteco_api/pull/37) | Docker API + Sidekiq, CORS/rack-attack, health check, `.env-example` |
| 2026-05 | [#38](https://github.com/Sartori-RIA/ubuteco_api/pull/38) | Order lifecycle services + AASM (see [06-order-lifecycle](./06-order-lifecycle.md)) |
| 2026-06 | [#39](https://github.com/Sartori-RIA/ubuteco_api/pull/39) | `ApiErrorRenderable` on all v1 controllers, Bullet + order preload, cross-tenant specs, rswag 422 alignment, i18n attribute labels (`config/locales/models/**`), deploy runbook draft, `platform_hardening_spec` |

---

## Definition of done

This plan has **no single finish line**. Close subsections independently; review quarterly.

---

## References

- [System architecture](../system-architecture.png)
- [api-conventions.md](./api-conventions.md)
- `docker-compose.yml` (infra + `api` + `sidekiq`)
- `config/initializers/cors.rb`
- `config/initializers/rack_attack.rb`
- `.github/workflows/ci.yml`
