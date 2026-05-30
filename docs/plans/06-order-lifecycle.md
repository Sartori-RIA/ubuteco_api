# Plan: Order lifecycle (domain)

**Status:** not started  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — testing](../../../ubuteco-react/docs/plans/05-testing.md) *(orders/kitchen regression)*  
**Priority:** P1  
**Depends on:** [01-multi-tenant](./01-multi-tenant.md) (recommended)  
**Estimated effort:** 1–2 sprints

---

## Goal

Centralize **order and order-item state rules** in explicit domain logic (state machine + services), reducing scattered callbacks and race conditions between HTTP requests, stock, and kitchen broadcasts.

---

## Current state

- `Order`: statuses include open/closed (enum).
- `OrderItem`: statuses (`awaiting`, `cooking`, `ready`, …), stock hooks on create/update/destroy.
- Kitchen broadcasts via `after_*_commit` on `OrderItem`.
- Front had race on `refreshOrder` vs `addOrderItem` (partially fixed with request ids).
- No formal transition matrix or invalid-state guards.

---

## Phase 1 — Document transitions

- [ ] State diagram for `Order` (open → closed, who can close)
- [ ] State diagram for `OrderItem` (dish vs non-dish, stock paths)
- [ ] Table: role × allowed action (waiter add item, kitchen update status, admin close org kitchen → auto-close orders)

**Acceptance:** diagram in this file or `docs/order-state-diagram.md`.

---

## Phase 2 — State machines (AASM or similar)

- [ ] `Order` state machine with guards (e.g. cannot add items when closed)
- [ ] `OrderItem` state machine; dish default `awaiting` on create
- [ ] Replace ad-hoc `saved_change_to_status?` checks where possible

**Acceptance:** invalid transitions raise / return 422 with clear error.

---

## Phase 3 — Service objects

- [ ] `Orders::AddItem.call(order:, params:)` — transaction, stock, broadcast
- [ ] `Orders::RemoveItem.call(...)`
- [ ] `Kitchen::UpdateItemStatus.call(...)`
- [ ] `Organizations::CloseKitchen` already closes orders — link to order close service

**Acceptance:** controllers thin; specs on services.

---

## Phase 4 — Events & side effects

- [ ] Single place for kitchen broadcast after successful commit
- [ ] `Order#recalculate_total` invoked consistently
- [ ] Idempotency consideration for duplicate add-item requests (optional header)

---

## Phase 5 — Tests

- [ ] Model/service specs for every transition
- [ ] Request specs: closed order rejects new items; org closed rejects kitchen update
- [ ] Regression: dish appears on order show without manual refresh (API response completeness)

---

## Definition of done

- [ ] Documented state diagrams
- [ ] AASM (or equivalent) on Order / OrderItem
- [ ] Core mutations via service objects
- [ ] Test coverage for invalid transitions

---

## References

- `app/models/order.rb`, `order_item.rb`
- `app/controllers/api/v1/orders_controller.rb`, `orders/items_controller.rb`
