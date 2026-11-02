# Inventory & stock

## Stockable products

Products with a `quantity_stock` column participate in inventory:

| Model | Stockable |
|-------|-----------|
| `Beer` | yes |
| `Wine` | yes |
| `Drink` | yes |
| `Food` | yes |
| `Dish` | no |

Detection in code: `OrderItem#stockable_item?` (`item.respond_to?(:quantity_stock)`).

## Policy

- **`quantity_stock` cannot go negative** — blocked on order item create/update and on manual adjustment.
- **Low stock threshold** — org-wide default via `LOW_STOCK_THRESHOLD` env (default `5`). Per-product threshold is future work.

## Order integration

- Create order item → reserves stock (`decrement!`).
- Destroy order item → releases stock (`increment!`).
- Quantity change → adjusts stock via `OrderItem#apply_quantity_change!`.
- Insufficient stock → validation error / `empty_stock` status path on orders.

## Manual adjustment API

`PATCH /api/v1/{beers|wines|drinks|foods}/:id/stock`

Body: `{ "adjustment": 5, "reason": "delivery" }` — `adjustment` is a signed integer delta; `reason` is optional and stored in `stock_movements`.

Authorized roles: **ADMIN**, **CASH_REGISTER**.

## Audit trail

Table `stock_movements`: `product` (polymorphic), `delta`, `reason`, `user_id`, `order_item_id`, `organization_id`, timestamps.

Written on:

- manual stock adjustment (`Inventory::AdjustStock`)
- order item create / destroy / quantity change (non-dish stockable products)

## Low stock

`GET /api/v1/inventory/low_stock` — items at or below threshold for the current org.

Authorized roles: **ADMIN**, **CASH_REGISTER**.

## Expiry

Beer and Food `valid_until` alerts: [product-expiry.md](./product-expiry.md).

## Restock suggestions

`GET /api/v1/inventory/restock_suggestions` — what to buy, from sales already stored in `stock_movements`.

Sales are movements with `order_item_id` and `delta < 0`. Manual adjustments are ignored. Average daily use is the units sold in the window divided by `window_days` (default 28, allowed 7–90). The window is calendar days in the organization timezone. Suggested quantity is `max(0, ceil(avg_daily × cover_days) − quantity_stock)`. `cover_days` defaults to `RESTOCK_COVER_DAYS` (7) and must be 1–60.

Fewer than 7 distinct sale days → `confidence: low` and `suggested_quantity: null`. Soft-deleted products are omitted. Dish is not stockable.

`?explain=1` adds `explanation` on up to 5 confident rows when `Ai.enabled_for?` is true. The sentence is dropped when it contains a number that is not in the computed facts. With AI off, the field is omitted and the list still returns.

Authorized roles: **ADMIN**, **CASH_REGISTER**.
