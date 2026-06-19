# Plan: Product expiry alerts (API)

**Status:** not started  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — expiry alerts UI](../../../ubuteco-react/docs/plans/15-product-expiry-alerts.md)  
**Branch:** `feature/product-expiry-alerts`  
**Priority:** P2  
**Depends on:** [09-inventory-stock](./09-inventory-stock.md) (recommended — same inventory surface)  
**Estimated effort:** 0.5–1 sprint

---

## Goal

Help org staff **see products nearing expiration** before they spoil — list endpoint, consistent date rules, and optional in-app signal. Builds on existing `valid_until` on **Beer** and **Food** (already in DB and partial API/UI).

---

## Current state

| Product | `valid_until` column | API permit/update | React edit/display |
|---------|---------------------|-------------------|-------------------|
| Beer | yes | yes | not exposed in UI yet |
| Food | yes | yes | yes (form + list) |
| Wine | no | — | — |
| Drink | no | — | — |
| Dish | no | — | — |

- No `expiring_soon` / `expired` query endpoint.
- No org-level “days before expiry” threshold (low stock uses `LOW_STOCK_THRESHOLD` env today).
- Date comparison must respect **org timezone** (see [i18n-and-money.md](../context/i18n-and-money.md)).

---

## Product decisions (lock before coding)

| Decision | Recommendation (v1) |
|----------|---------------------|
| Which products | **Beer + Food** only (column already exists) |
| “Expiring soon” window | Org-configurable days ahead, default **7** (env `EXPIRY_WARNING_DAYS` fallback like low stock) |
| Already expired | Include in same list with `status: expired` or separate section — **same endpoint**, sorted by date |
| Notifications v1 | **In-app list only** — no email, push, or Sidekiq digest |
| Block orders on expired product | **Out of scope v1** — alert only |
| Extend `valid_until` to wine/drink | **Phase 2 optional** — separate migration if needed |
| Null `valid_until` | Excluded from expiring/expired lists |

---

## Out of scope (v1)

- Email / push / ActionCable notifications
- Automatic write-off or stock adjustment on expiry
- Customer-facing warnings on menu
- Subscription feature gating

---

## Phase 1 — Domain & query

- [ ] Document expiry rules in `docs/context/product-expiry.md` (mirror [inventory-stock.md](../context/inventory-stock.md))
- [ ] `Inventory::ExpiringProductsQuery` (or `Catalog::ExpiringProductsQuery`):
  - Scope: `organization_id`, models with `valid_until` (Beer, Food)
  - Compare calendar dates in org timezone (`SetOrganizationRegional` / org `timezone`)
  - Return `{ product_type, id, name, valid_until, days_remaining, status: expiring|expired }`
- [ ] Shared module listing expiry-capable model classes (avoid hardcoding in controller)

**Acceptance:** unit spec for boundary dates (today, tomorrow, yesterday, null `valid_until`).

---

## Phase 2 — API

- [ ] `GET /api/v1/inventory/expiring` (or `/catalog/expiring`) — same auth as `low_stock` (`:read, :inventory`)
- [ ] Response: `{ warning_days:, items: [...] }` (parallel to low_stock `{ threshold:, items: }`)
- [ ] Optional query param `include_expired=true` (default true)
- [ ] rswag + `openapi:drift_check`
- [ ] Ensure Beer/Food JSON consistently exposes `valid_until` on index/show (verify jbuilder)

**Acceptance:** request specs; cross-tenant spec (org A cannot see org B items).

---

## Phase 3 — Authorization & roles

- [ ] Same roles as low stock: **ADMIN**, **CASH_REGISTER** read `:inventory`
- [ ] Waiter/kitchen: no access (match [inventory-stock.md](../context/inventory-stock.md))

---

## Phase 4 — Tests

- [ ] Service/query specs (timezone edge cases)
- [ ] Request spec for `GET .../expiring`
- [ ] Cross-tenant: `spec/security/cross_tenant/` case
- [ ] Mirror patterns from `spec/requests/inventory_spec.rb`

---

## Phase 5 — Optional follow-ups

- [ ] Migration: add `valid_until` to Wine, Drink if product owner confirms
- [ ] Org setting `expiry_warning_days` column (replace env-only default)
- [ ] Sidekiq daily job + notification table (v2 plan)

---

## Manual steps

- [ ] No migration required for v1 (columns exist on beers, foods)
- [ ] If Phase 5 wine/drink: `bin/rails db:migrate` when DB available

---

## Definition of done

- [ ] API lists expiring and expired beers/foods for current org
- [ ] Date logic uses org timezone
- [ ] Swagger documented; CI drift check passes
- [ ] Context doc published; companion React plan linked

---

## References

- `app/services/inventory/low_stock_query.rb` — pattern to mirror
- `app/controllers/api/v1/inventory_controller.rb`
- `app/controllers/api/v1/beers_controller.rb`, `foods_controller.rb`
- [09-inventory-stock.md](./09-inventory-stock.md)
- [docs/context/inventory-stock.md](../context/inventory-stock.md)
