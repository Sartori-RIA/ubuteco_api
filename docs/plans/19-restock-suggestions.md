# Plan: Restock suggestions (forecast + optional AI explanation)

**Status:** not started  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — restock tab](../../../ubuteco-react/docs/plans/19-restock-suggestions.md)  
**Branch:** `feature/restock-suggestions`  
**Priority:** P2  
**Depends on:** [09-inventory-stock](./09-inventory-stock.md); [16-ai-foundation](./16-ai-foundation.md) only for Phase 3  
**Estimated effort:** 1 sprint

---

## Goal

Answer *"what do I need to buy, and how much?"* using the consumption already recorded in `stock_movements`.

**This is mostly statistics, not AI.** Phases 1–2 work with no model at all. The model is optional (Phase 3) and only explains the numbers in plain language. Doing it this way keeps the suggestions predictable and testable.

---

## Product decisions (lock before coding)

| Decision | Recommendation (v1) |
|----------|---------------------|
| Products | Stockable only: Beer, Wine, Drink, Food (Dish has no stock) |
| Consumption source | `stock_movements` with `order_item_id` present and `delta < 0` (sales), excluding manual adjustments |
| Method | Average daily consumption over last **28 days** in org timezone; weekday-weighted in v2 |
| Target | Cover **7 days** (org setting later; env `RESTOCK_COVER_DAYS` default 7) |
| Suggested qty | `max(0, ceil(avg_daily × cover_days) − quantity_stock)` |
| Insufficient history | < 7 days of sales → `confidence: low`, no quantity, just flag |
| Who | **ADMIN**, **CASH_REGISTER** (`:read, :inventory`) |
| Supplier / purchase orders | Out of scope |

---

## Out of scope (v1)

- Purchase orders, supplier integration
- Seasonality, holidays, events
- Dish ingredient explosion (consumption of Food through `dish_ingredients`) — v2

---

## Phase 1 — Forecast query

- [ ] `Inventory::RestockSuggestionsQuery` (org-scoped, SQL aggregate over `stock_movements` by `product_type, product_id`, day buckets in org timezone)
- [ ] Output per product: `product_type, id, name, quantity_stock, avg_daily, days_of_cover, suggested_quantity, confidence`
- [ ] Sort by `days_of_cover` ascending
- [ ] Uses index `(organization_id, created_at)` — verify with `EXPLAIN` on seeded data

**Acceptance:** specs for: no history, < 7 days, steady consumption, manual adjustments ignored, soft-deleted products excluded, timezone boundary.

---

## Phase 2 — API

- [ ] `GET /api/v1/inventory/restock_suggestions` → `{ cover_days:, window_days:, items: [...] }` (parallel to `low_stock`)
- [ ] Optional params: `cover_days` (1–60), `window_days` (7–90)
- [ ] rswag + drift check
- [ ] Update `docs/context/inventory-stock.md`

**Acceptance:** request specs; cross-tenant spec; WAITER/KITCHEN denied.

---

## Phase 3 — AI explanation (optional)

- [ ] `?explain=1` → adds `explanation` per top-N items via `Ai::Client` (`feature: RESTOCK_EXPLAIN`, `tier: :fast`), e.g. *"Sells ~6/day, 4 left — runs out tomorrow."*
- [ ] Model receives only the computed numbers; same number guard as [18](./18-ai-daily-brief.md)
- [ ] Gated by `Ai.enabled_for?`; without AI the field is omitted (not an error)

**Acceptance:** spec with `Ai::FakeClient`; disabled path returns suggestions without explanations.

---

## Manual steps

- [ ] None for Phases 1–2 (no migration)

---

## Definition of done

- [ ] Suggestions endpoint live, documented, tested across tenants and timezones
- [ ] Context doc updated
- [ ] Optional AI explanation behind org opt-in

---

## References

- `app/models/stock_movement.rb`, `app/services/inventory/record_movement.rb`
- `app/services/inventory/low_stock_query.rb` (pattern to mirror)
- [docs/context/inventory-stock.md](../context/inventory-stock.md)
