# Plan: Inventory & stock

**Status:** completed  
**Project:** ubuteco_api (primary)  
**Branch:** `feature/inventory-stock`  
**Companion:** [ubuteco-react — inventory UI](../../../ubuteco-react/docs/plans/11-inventory-ui.md)  
**Priority:** P2  
**Depends on:** [06-order-lifecycle](./06-order-lifecycle.md) (recommended)  
**Estimated effort:** 1 sprint

---

## Goal

First-class **stock management** for stockable products (beer, wine, drink, food — not dishes): visibility, manual adjustments, low-stock signals, and consistent reservation with orders.

---

## Current state

- `quantity_stock` on Beer, Wine, Drink, Food (not Dish).
- `OrderItem` reserves/releases stock on create/destroy; validates on create; status `empty_stock`.
- Controllers return generic `Insufficient stock` on failure.
- No dedicated inventory API or audit trail of movements.

---

## Phase 1 — Product rules

- [x] Document which types are stockable (already `stockable_item?` on OrderItem) — see [inventory-stock.md](../context/inventory-stock.md)
- [x] Policy: can `quantity_stock` go negative? (currently blocked)
- [x] Optional: `low_stock_threshold` per product or org default — org default via `LOW_STOCK_THRESHOLD` env

---

## Phase 2 — API

- [x] `PATCH /api/v1/beers/:id/stock` (and wines, drinks, foods) — admin only, `{ adjustment: +5, reason: "delivery" }`
- [x] Nested adjust via product routes; audit in `stock_movements` (see Phase 3)
- [x] `GET /api/v1/inventory/low_stock` — items below threshold for org
- [x] Include `quantity_stock` in list/show JSON (verify already exposed)

---

## Phase 3 — Audit (optional MVP+)

- [x] Table `stock_movements`: product_type, product_id, delta, reason, user_id, order_item_id, created_at
- [x] Write on order item create/destroy and manual adjustment

---

## Phase 4 — Authorization

- [x] Only ADMIN (and optionally CASH_REGISTER) adjust stock
- [x] Waiter/kitchen read-only or hidden

---

## Phase 5 — Tests

- [x] Order reserves stock; cancel restores — covered in `orders/*_spec` (plan 06)
- [x] Concurrent orders last unit — one succeeds, one fails (`spec/models/stock_reservation_spec.rb`)
- [x] Manual adjustment updates `quantity_stock` — `spec/services/inventory/adjust_stock_spec.rb`, `spec/requests/inventory_spec.rb`

---

## Definition of done

- [x] Admin can adjust stock via API
- [x] Low-stock list endpoint or documented query
- [x] Front inventory UI (companion plan) or documented manual use of product edit

---

## References

- [docs/context/inventory-stock.md](../context/inventory-stock.md) — stockable types, policies, API
- `app/models/order_item.rb` — `reserve_stock_unless_dish`, `sufficient_stock_available`
