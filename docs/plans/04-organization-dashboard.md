# Plan: Organization dashboard (charts & analytics)

**Status:** completed  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — dashboard](../../../ubuteco-react/docs/plans/04-organization-dashboard.md)  
**Branch:** `feature/organization-dashboard`  
**Priority:** P1  

---

## Phase 3 — API endpoints

- [x] `GET /api/v1/dashboard/summary?from=&to=`
- [x] `GET /api/v1/dashboard/series?from=&to=&grain=day&metric=revenue`
- [x] `GET /api/v1/dashboard/kitchen?from=&to=`
- [x] Jbuilder responses; cents as integers + currency field
- [x] Authorize: admin/cash_register via `:dashboard` ability

---

## Phase 4 — Performance

- [x] Indexes: `(organization_id, created_at)`, `(organization_id, status, created_at)` — migration `20260527180000`
- [x] Rails.cache key TTL 3 min (`Organizations::Dashboard::Cache`)
- [ ] Optional later: rollup table + Sidekiq

---

## Phase 5 — Plan gating (when [03-subscription-plans](./03-subscription-plans.md) exists)

- [ ] `feature?(:dashboard)` on endpoints

---

## Phase 6 — Tests & Swagger

- [x] Service + request specs (summary, series, kitchen, cache)
- [x] OpenAPI definitions for dashboard tags in `swagger/v1/swagger.yaml`

---

## Definition of done (MVP)

- [x] Summary + revenue series + kitchen endpoints live
- [x] Tenant-scoped, timezone-aware
- [x] Swagger documented
- [x] Front charts consume API (companion plan)

**Run migration:** `bin/rails db:migrate` (adds dashboard query indexes on `orders`).
