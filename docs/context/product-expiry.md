# Product expiry

Plan: [15-product-expiry-alerts](../plans/15-product-expiry-alerts.md). Stock rules stay in [inventory-stock.md](./inventory-stock.md).

## Which products

`valid_until` exists on **Beer** and **Food** only. Wine, Drink, and Dish are out of the expiry list. `Inventory::EXPIRY_CLASSES` is the list the query uses.

A null `valid_until` means the product is not tracked and is omitted.

## Calendar day

`valid_until` is a timestamp. The expiry **date** is that timestamp's calendar day in the **organization timezone**, and "today" is the same zone. Do not compare the raw UTC date.

Example: `2026-11-02 02:00 UTC` is 1 Nov in `America/Sao_Paulo` and still 1 Nov late evening in `America/Toronto`. Combined with "now", the same row can be expired in one org and expiring today in the other.

`days_remaining` is `expiry_date - today` in that zone. `0` is today (status `expiring`). Negative is `expired`.

## Warning window

`EXPIRY_WARNING_DAYS` (default `7`), same shape as `LOW_STOCK_THRESHOLD`: one env value for every org. A product expiring later than that window is omitted. An org column is a later plan, not v1.

Expired rows are included by default. `GET /api/v1/inventory/expiring?include_expired=false` drops them.

## API

`GET /api/v1/inventory/expiring`

```json
{
  "warning_days": 7,
  "items": [
    {
      "product_type": "beers",
      "id": 1,
      "name": "IPA",
      "valid_until": "2026-11-01T15:00:00Z",
      "days_remaining": -1,
      "status": "expired"
    }
  ]
}
```

Sorted by expiry date, then name. `product_type` is the route key (`beers`, `foods`), same as low stock.

Authorized roles: **ADMIN**, **CASH_REGISTER** (`:read, :inventory`). Waiter and kitchen are forbidden.

v1 does not block orders, send email, or adjust stock when a product expires. Beer and Food JSON already include `valid_until` on index/show.

## Key files

```
app/models/inventory.rb
app/services/inventory/expiring_products_query.rb
app/controllers/api/v1/inventory_controller.rb
```
