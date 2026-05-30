# Plan: Inventory & stock

**Status:** not started  
**Project:** ubuteco_api (primary)  
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

- [ ] Document which types are stockable (already `stockable_item?` on OrderItem)
- [ ] Policy: can `quantity_stock` go negative? (currently blocked)
- [ ] Optional: `low_stock_threshold` per product or org default

---

## Phase 2 — API

- [ ] `PATCH /api/v1/beers/:id/stock` (and wines, drinks, foods) — admin only, `{ adjustment: +5, reason: "delivery" }`
- [ ] Or nested: `POST .../stock_adjustments` with audit log
- [ ] `GET /api/v1/inventory/low_stock` — items below threshold for org
- [ ] Include `quantity_stock` in list/show JSON (verify already exposed)

---

## Phase 3 — Audit (optional MVP+)

- [ ] Table `stock_movements`: product_type, product_id, delta, reason, user_id, order_item_id, created_at
- [ ] Write on order item create/destroy and manual adjustment

---

## Phase 4 — Authorization

- [ ] Only ADMIN (and optionally CASH_REGISTER) adjust stock
- [ ] Waiter/kitchen read-only or hidden

---

## Phase 5 — Tests

- [ ] Order reserves stock; cancel restores
- [ ] Concurrent orders last unit — one succeeds, one fails
- [ ] Manual adjustment updates `quantity_stock`

---

## Definition of done

- [ ] Admin can adjust stock via API
- [ ] Low-stock list endpoint or documented query
- [ ] Front inventory UI (companion plan) or documented manual use of product edit

---

## References

- `app/models/order_item.rb` — `reserve_stock_unless_dish`, `sufficient_stock_available`
