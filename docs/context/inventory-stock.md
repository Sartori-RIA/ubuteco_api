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
