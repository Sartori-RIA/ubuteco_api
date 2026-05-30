# Plan: Organization dashboard (charts & analytics)

**Status:** not started  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — dashboard](../../../ubuteco-react/docs/plans/04-organization-dashboard.md)  
**Priority:** P1  
**Depends on:** [01-multi-tenant](./01-multi-tenant.md), [02-locale-and-currency](./02-locale-and-currency.md) (timezone)  
**Estimated effort:** 1–2 sprints (MVP); +1 for kitchen metrics & caching

---

## Goal

Dedicated analytics API for organization admins: summary KPIs and time-series for charts (revenue, orders, mix by item type). Scoped strictly to tenant; optimized for typical date ranges.

---

## Current state

- Orders have `total_cents`, `status`, `organization_id`, timestamps.
- Order items have `item_type`, `quantity`, dish status for kitchen.
- No aggregation endpoints; clients would misuse `orders#index` + search.

---

## Product decisions

| Decision | Recommendation |
|----------|----------------|
| Default range | Last 7 days |
| Max range | 90 days (MVP) |
| Grain | `day` (MVP); `hour` optional for “today” |
| Roles | `ADMIN`, `CASH_REGISTER` read; `WAITER` optional read-only |
| Currency | Aggregate only within org default currency (single currency per org in v1) |

---

## Phase 1 — Metrics definition

Document KPIs (single source of truth):

| Metric | SQL concept |
|--------|-------------|
| `revenue_cents` | sum closed orders `total_cents` in range |
| `orders_count` | count orders created in range |
| `open_orders_count` | current open orders |
| `average_ticket_cents` | revenue / closed orders |
| `items_by_type` | group order_items by `item_type` |
| `kitchen_avg_prep_seconds` | optional: `updated_at - created_at` for dish items reaching `ready` |

- [ ] Write `docs/plans/dashboard-metrics.md` appendix or section in this file when finalized

---

## Phase 2 — Service layer

- [ ] `Organizations::Dashboard::Summary.call(org:, from:, to:)`
- [ ] `Organizations::Dashboard::Series.call(org:, from:, to:, grain: :day, metric: :revenue)`
- [ ] Use org `timezone` for bucket boundaries ([02-locale-and-currency](./02-locale-and-currency.md))
- [ ] Input validation: `from <= to`, max span 90 days

**Acceptance:** service specs with frozen time and fixture orders.

---

## Phase 3 — API endpoints

- [ ] `GET /api/v1/dashboard/summary?from=&to=` (org from `Current.organization`)
- [ ] `GET /api/v1/dashboard/series?from=&to=&grain=day&metric=revenue`
- [ ] Optional: `GET /api/v1/dashboard/kitchen?from=&to=`
- [ ] Jbuilder or blueprint responses; cents as integers + currency field
- [ ] Authorize: admin/cash_register abilities

**Acceptance:** request specs; cross-tenant denied.

---

## Phase 4 — Performance

- [ ] Indexes: `(organization_id, created_at)`, `(organization_id, status, created_at)`
- [ ] Redis cache key: `dashboard:org:#{id}:summary:#{from}:#{to}` TTL 2–5 min
- [ ] Optional later: `daily_organization_stats` table + nightly Sidekiq rollup

---

## Phase 5 — Plan gating (when [03-subscription-plans](./03-subscription-plans.md) exists)

- [ ] `feature?(:dashboard)` on endpoints
- [ ] Free plan: summary only; paid: full series

---

## Phase 6 — Tests & Swagger

- [ ] Service + request specs (empty range, single day, timezone edge around midnight)
- [ ] OpenAPI definitions for dashboard tags

---

## Risks

| Risk | Mitigation |
|------|------------|
| Slow queries on large orgs | Cache + indexes; rollup table later |
| Open vs closed revenue | Document metric; separate `open_orders` KPI |

---

## Definition of done (MVP)

- [ ] Summary + revenue series endpoints live
- [ ] Tenant-scoped, timezone-aware
- [ ] Swagger documented
- [ ] Front charts consume API (companion plan)

---

## References

- `app/models/order.rb`, `order_item.rb`
- `operational_status` on organization (optional KPI: hours open)
