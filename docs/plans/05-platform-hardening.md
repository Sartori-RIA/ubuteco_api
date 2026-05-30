# Plan: Platform hardening (API)

**Status:** not started  
**Project:** ubuteco_api  
**Priority:** Ongoing (parallel to feature plans)  
**Estimated effort:** spread across sprints

---

## Goal

Cross-cutting improvements: security, API consistency, performance, observability, and production readiness. Not a single release — track by subsection.

---

## 1. Security & authorization

- [ ] **IDOR audit** — covered in [01-multi-tenant](./01-multi-tenant.md); re-verify after each new resource
- [ ] **rack-attack**: throttle `/auth/sign_in`, `/auth/sign_up`, search endpoints
- [ ] **JWT**: document expiry; consider refresh token or denylist on logout
- [ ] **CORS**: replace `origins '*'` with env-based allowlist in staging/production
- [ ] **AnyCable**: explicit `ANYCABLE_ALLOWED_ORIGINS` in prod; rotate `ANYCABLE_SECRET`
- [ ] **Secrets**: no secrets in repo; credentials/env for JWT, AnyCable, OpenSearch

**Done when:** Brakeman + bundler-audit clean; rate limits in staging.

---

## 2. API design & consistency

- [ ] **Error format** standard:
  ```json
  { "errors": [{ "code": "validation_error", "field": "email", "message": "..." }] }
  ```
- [ ] Migrate controllers gradually from `render json: model.errors.full_messages`
- [ ] **Service objects** for multi-step flows:
  - `Orders::AddItem`, `Orders::RecalculateTotal`
  - `Kitchen::UpdateItemStatus`
  - `Organizations::CloseKitchen`
- [ ] **State machines** (AASM) for `Order` and `OrderItem` status transitions
- [ ] **Idempotency-Key** header on `POST` order items / create order (optional Redis store)
- [ ] **Serializers**: evaluate Blueprinter vs Jbuilder consistency

**Done when:** style guide in `docs/plans/api-conventions.md` (create when starting).

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
- [ ] **Health check** `/up`: extend with Redis ping (optional OpenSearch)
- [ ] **Sidekiq**: monitor dead queue; alert on growth
- [ ] **Action Cable / AnyCable**: keep dev transmit logs; reduce noise in prod

**Done when:** single log line per request with tenant context in staging.

---

## 5. Quality & CI

- [ ] **Cross-tenant specs** — [01-multi-tenant](./01-multi-tenant.md)
- [ ] **OpenAPI / rswag** synced with controllers (kitchen, operational_status, dashboard when added)
- [ ] **Parallel specs** stable in CI
- [ ] **Coverage** threshold for models/abilities/services (team choice)

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
- [ ] Document dev stack in [README](../README.md#system-architecture)

---

## Suggested order (within hardening)

1. Security (CORS, rate limit) — quick wins  
2. Error format + one service object pilot  
3. Bullet / N+1  
4. Logging  
5. Production infra before go-live  

---

## Definition of done

This plan has **no single finish line**. Close subsections independently; review quarterly.

---

## References

- [System architecture](../system-architecture.png)
- `config/initializers/cors.rb`
- `config/initializers/rack_attack.rb` (create if missing)
- `.github/` / `config/ci.rb`
