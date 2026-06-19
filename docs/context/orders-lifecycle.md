# Orders & kitchen lifecycle

Stable reference for order domain behaviour. For implementation history, see [plan 06](../plans/06-order-lifecycle.md). State diagrams: [order-state-diagram.md](../order-state-diagram.md).

## Key models

| Model | Notes |
|-------|-------|
| `Order` | AASM states: `open`, `closed`, `payed` |
| `OrderItem` | AASM states; dish vs non-dish paths differ |
| `Organization#operational_status` | `open` / `closed` — kitchen shutdown bulk-closes open orders |

## Domain services (use these, don't bypass in controllers)

| Service | When |
|---------|------|
| `Orders::AddItem` | Add line to open order (+ stock side effects) |
| `Orders::UpdateItem` | Update quantity/status with stock adjustment |
| `Orders::RemoveItem` | Remove line and release stock |
| `Kitchen::UpdateItemStatus` | Kitchen status transition (org/kitchen guards) |
| `Kitchen::BroadcastOrderItem` | **Only** AnyCable entry point for kitchen payloads |
| `Organizations::CloseKitchen` | Bulk-close open orders when org kitchen closes |

Controllers under `app/controllers/api/v1/orders/` and `kitchens_controller.rb` should stay thin — delegate to services.

## Order states

| Transition | Who / trigger |
|------------|---------------|
| `open` → `closed` | Staff via `PATCH /api/v1/orders/:id`; **auto** when org kitchen closes |
| `open` / `closed` → `payed` | Staff with order update permission |
| `payed` | Terminal — no reopen |

**Guards:** items can only be created/updated/destroyed while order is `open`. Org kitchen **closed** → kitchen API returns empty queue / 403 on status updates.

## Order item — dish (kitchen queue)

- Default status on create: `awaiting`
- Flow: `awaiting` → `cooking` → `ready` → `with_the_client` (or `canceled`)
- Kitchen broadcast fires on **create** and **status change** when order and org are both `open`
- Kitchen role uses `/api/v1/kitchens/:id`; other roles may update via order items API

## Order item — stock-backed products

- Types: `Beer`, `Wine`, `Drink`, `Food` (not `Dish`) — see [inventory-stock.md](./inventory-stock.md)
- Create reserves stock; destroy releases; quantity change adjusts via `OrderItem#apply_quantity_change!`
- Statuses `cooking`, `ready`, `empty_stock` are **not** valid on non-dish lines

## API routes

```
GET/POST   /api/v1/orders
GET/PATCH/DELETE /api/v1/orders/:id
GET/POST   /api/v1/orders/:order_id/items
PATCH/DELETE     /api/v1/orders/:order_id/items/:id
GET/PATCH  /api/v1/kitchens/:id
```

## Common errors

| Code | HTTP | When |
|------|------|------|
| `validation_error` | 422 | Invalid transition, closed order mutation |
| `insufficient_stock` | 422 | Stock guard on create/update quantity |
| `kitchen_closed` | 403 | Kitchen action when org operational status is closed |

Use `render_model_errors` / `render_i18n_api_error` — see [api-conventions.md](./api-conventions.md).

## Testing

- Lifecycle guards: `spec/requests/order_lifecycle_spec.rb`
- Cross-tenant: `spec/security/cross_tenant/orders_create_spec.rb`, `access_spec.rb`
- Stock concurrency: `spec/models/stock_reservation_spec.rb`

## AI pitfalls

- Do not add items to a `closed` or `payed` order.
- Do not broadcast kitchen events outside `Kitchen::BroadcastOrderItem`.
- Do not skip stock hooks on stockable products.
- Dish items use kitchen queue; drinks/food use stock path — different state machines.
