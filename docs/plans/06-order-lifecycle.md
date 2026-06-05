# Plan: Order lifecycle (domain)

**Status:** completed  
**Project:** ubuteco_api (primary)  
**GitHub:** [Sartori-RIA/ubuteco_api#38](https://github.com/Sartori-RIA/ubuteco_api/pull/38) (merged)  
**Branch:** `master`  
**Companion:** [ubuteco-react — testing](../../../ubuteco-react/docs/plans/05-testing.md) *(orders/kitchen regression)*  
**Priority:** P1  
**Depends on:** [01-multi-tenant](./01-multi-tenant.md) (recommended)  
**Estimated effort:** 1–2 sprints

---

## Goal

Centralize **order and order-item state rules** in explicit domain logic (state machine + services), reducing scattered callbacks and race conditions between HTTP requests, stock, and kitchen broadcasts.

---

## Current state

- `Order` / `OrderItem`: AASM state machines with guards and 422 on invalid transitions.
- Kitchen broadcasts via `Kitchen::BroadcastOrderItem` (model callbacks).
- Mutations via service objects (`Orders::*`, `Kitchen::UpdateItemStatus`, `Organizations::CloseKitchen`).
- Controllers thin; `ApiErrorRenderable` returns structured errors (#39).
- Optional follow-up: idempotency header for duplicate add-item (see Phase 4).

---

## Phase 1 — Document transitions

- [x] State diagram for `Order` (open → closed, who can close)
- [x] State diagram for `OrderItem` (dish vs non-dish, stock paths)
- [x] Table: role × allowed action (waiter add item, kitchen update status, admin close org kitchen → auto-close orders)

**Acceptance:** diagram in this file or `docs/order-state-diagram.md`.

---

## Phase 2 — State machines (AASM or similar)

- [x] `Order` state machine with guards (e.g. cannot add items when closed)
- [x] `OrderItem` state machine; dish default `awaiting` on create
- [x] Replace ad-hoc `saved_change_to_status?` checks where possible — broadcast delegated to `Kitchen::BroadcastOrderItem`

**Acceptance:** invalid transitions raise / return 422 with clear error.

---

## Phase 3 — Service objects

- [x] `Orders::AddItem.call(order:, params:)` — transaction, stock, broadcast
- [x] `Orders::RemoveItem.call(...)`
- [x] `Orders::UpdateItem.call(...)` — quantity/status + stock
- [x] `Kitchen::UpdateItemStatus.call(...)`
- [x] `Organizations::CloseKitchen` — extracted from org callback; closes open orders

**Acceptance:** controllers thin; specs on services.

---

## Phase 4 — Events & side effects

- [x] Single place for kitchen broadcast — `Kitchen::BroadcastOrderItem` (called from model callbacks)
- [x] `Order#recalculate_total` invoked consistently — via OrderItem callbacks
- [ ] Idempotency consideration for duplicate add-item requests (optional header)

---

## Phase 5 — Tests

- [x] Model/service specs for every transition (initial set)
- [x] Request specs: closed order rejects new items; org closed rejects kitchen update
- [x] Regression: new item appears on order items index after create

---

## Definition of done

- [x] Documented state diagrams
- [x] AASM (or equivalent) on Order / OrderItem
- [x] Core mutations via service objects
- [x] Test coverage for invalid transitions (initial set)

---

## References

- `docs/order-state-diagram.md`
- `app/controllers/api/v1/orders_controller.rb`, `orders/items_controller.rb`
