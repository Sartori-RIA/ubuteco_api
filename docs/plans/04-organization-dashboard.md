# Plan: Organization dashboard (charts & analytics)

**Status:** in progress  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — dashboard](../../../ubuteco-react/docs/plans/04-organization-dashboard.md)  
**Branch:** `feature/organization-dashboard`  
**Priority:** P1  
**Depends on:** [01-multi-tenant](./01-multi-tenant.md), [02-locale-and-currency](./02-locale-and-currency.md) (timezone)  
**Estimated effort:** 1–2 sprints (MVP); +1 for kitchen metrics & caching

---

## Goal

Dedicated analytics API for organization admins: summary KPIs and time-series for charts (revenue, orders, mix by item type). Scoped strictly to tenant; optimized for typical date ranges.

---

## Metrics (MVP)

| Metric | Definition |
|--------|------------|
| `revenue_cents` | Sum `total_cents` of orders with status `closed` or `payed` created in range |
| `orders_count` | Count all orders created in range |
| `open_orders_count` | Current open orders (snapshot) |
| `average_ticket_cents` | `revenue_cents / completed_orders_count` |
| `items_by_type` | Sum `order_items.quantity` grouped by `item_type` on completed orders in range |

Default range: last 7 days. Max span: 90 days. Day buckets use org `timezone`.

---

## Phase 1 — Metrics definition

- [x] KPI definitions documented above

---

## Phase 2 — Service layer

- [x] `Organizations::Dashboard::Summary.call(org:, from:, to:)`
- [x] `Organizations::Dashboard::Series.call(org:, from:, to:, grain: :day, metric: :revenue)`
- [x] `Organizations::Dashboard::RangeParser` — org timezone, max 90 days
- [x] Service specs with fixture orders

---

## Phase 3 — API endpoints

- [x] `GET /api/v1/dashboard/summary?from=&to=`
- [x] `GET /api/v1/dashboard/series?from=&to=&grain=day&metric=revenue`
- [ ] Optional: `GET /api/v1/dashboard/kitchen?from=&to=`
- [x] Jbuilder responses; cents as integers + currency field
- [x] Authorize: admin/cash_register via `:dashboard` ability

---

## Phase 4 — Performance

- [ ] Indexes: `(organization_id, created_at)`, `(organization_id, status, created_at)`
- [ ] Redis cache key TTL 2–5 min
- [ ] Optional later: rollup table + Sidekiq

---

## Phase 5 — Plan gating (when [03-subscription-plans](./03-subscription-plans.md) exists)

- [ ] `feature?(:dashboard)` on endpoints

---

## Phase 6 — Tests & Swagger

- [x] Service + request specs
- [ ] OpenAPI definitions for dashboard tags

---

## Definition of done (MVP)

- [x] Summary + revenue series endpoints live
- [x] Tenant-scoped, timezone-aware
- [ ] Swagger documented
- [x] Front charts consume API (companion plan)

---

## References

- `app/services/organizations/dashboard/`
- `app/controllers/api/v1/dashboard_controller.rb`
