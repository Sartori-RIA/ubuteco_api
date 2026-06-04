# Plan: Platform hardening (API)

**Status:** in progress  
**Project:** ubuteco_api  
**Branch:** `feature/platform-hardening`  
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
- [~] Migrate controllers gradually from `render json: model.errors.full_messages` — pilot: `Orders::ItemsController`
- [ ] **Service objects** for multi-step flows:
  - `Orders::AddItem`, `Orders::RecalculateTotal`
  - `Kitchen::UpdateItemStatus`
  - `Organizations::CloseKitchen`
- [ ] **State machines** (AASM) for `Order` and `OrderItem` status transitions
- [ ] **Idempotency-Key** header on `POST` order items / create order (optional Redis store)
- [ ] **Serializers**: evaluate Blueprinter vs Jbuilder consistency

**Done when:** style guide maintained in [api-conventions.md](./api-conventions.md); legacy error arrays migrated incrementally.

---

## 3. Performance

- [ ] **Bullet** in development; fix N+1 on orders#show, kitchens#index, list endpoints
- [ ] **Strict loading** (`strict_loading_by_default` in dev) on hot paths
- [ ] **Searchkick**: scope reindex jobs; avoid full-class `ReindexJob` without org filter
- [ ] **Database**: review composite indexes with [04-organization-dashboard](./04-organization-dashboard.md)
- [ ] **Fragment caching** — low priority for API-only; skip unless HTML partials grow

**Done when:** Bullet warnings zero on main user flows.

---

## 4. Observability

- [ ] **Structured logging**: org_id, user_id, request_id in Lograge/JSON logs
- [x] **Health check** `/up`: extend with Redis ping (optional OpenSearch)
- [ ] **Sidekiq**: monitor dead queue; alert on growth
- [ ] **Action Cable / AnyCable**: keep dev transmit logs; reduce noise in prod

**Done when:** single log line per request with tenant context in staging.

---

## 5. Quality & CI

- [ ] **Cross-tenant specs** — [01-multi-tenant](./01-multi-tenant.md)
- [ ] **OpenAPI / rswag** synced with controllers (kitchen, operational_status, dashboard when added)
- [ ] **Parallel specs** stable in CI
- [ ] **Coverage** threshold for models/abilities/services (team choice)
- [x] **Brakeman + bundler-audit** in GitHub Actions

**Done when:** CI required checks documented in README.

---

## 6. Production infrastructure

- [ ] **Active Storage** → S3 + CDN URLs
- [ ] **Sidekiq queues**: `default`, `searchkick`, `mailers` with concurrency config
- [ ] **OpenSearch**: managed cluster URL via env; security plugin in prod
- [ ] **AnyCable**: separate `anycable-go` service; not `allowed_origins *`
- [ ] **Deploy runbook**: link from README (Procfile, env vars, migrations, reindex)

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
- [ ] **Dev vs host transition** — optional compose profile for infra-only (host Rails)
- [ ] **Staging / deploy path** — same image in staging; link to deploy runbook in §6

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
