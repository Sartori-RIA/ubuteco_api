# Organization dashboard

Stable reference for analytics endpoints. Plan: [04-organization-dashboard](../plans/04-organization-dashboard.md).

## Endpoints

All require auth + `:read, :dashboard` ability (typically **ADMIN**, **CASH_REGISTER**).

| Method | Path | Params |
|--------|------|--------|
| GET | `/api/v1/dashboard/summary` | `from`, `to` (ISO8601 dates) |
| GET | `/api/v1/dashboard/series` | `from`, `to`, `grain` (default `day`), `metric` (default `revenue`) |
| GET | `/api/v1/dashboard/kitchen` | `from`, `to` |

Tenant: scoped to `Current.organization` — controller returns **403** if org missing.

## Date ranges

Parsed by `Organizations::Dashboard::RangeParser`:

- Uses **org timezone** (`organization.timezone`) for day boundaries — not server UTC.
- Max span: **90 days** (`MAX_SPAN_DAYS`).
- Invalid range → **422** with `code: invalid_range`.

## Services

| Service | Role |
|---------|------|
| `Organizations::Dashboard::Summary` | Aggregates for summary card |
| `Organizations::Dashboard::Series` | Time series (revenue, etc.) |
| `Organizations::Dashboard::Kitchen` | Kitchen metrics |
| `Organizations::Dashboard::RangeParser` | Timezone-aware from/to |
| `Organizations::Dashboard::Cache` | Rails.cache, **3 min TTL** |

Controller stays thin — call services inside `Cache.fetch`.

## Response shape

- Money as **integer cents** + currency field (money-rails pattern).
- Jbuilder views under `app/views/api/v1/dashboard/`.

## Performance

- DB indexes on `orders`: `(organization_id, created_at)`, `(organization_id, status, created_at)`.
- Cache key: `dashboard:org:{id}:{kind}:{params...}`.

## Future gating

When [subscription plans](../plans/03-subscription-plans.md) ships, endpoints may check `feature?(:dashboard)`.

## Key files

```
app/controllers/api/v1/dashboard_controller.rb
app/services/organizations/dashboard/
app/models/abilities/base_ability.rb  # dashboard_permissions
spec/requests/api/v1/dashboard_spec.rb
```

## AI pitfalls

- Do not query orders without `organization_id` scope.
- Dashboard dates must respect org timezone — use `RangeParser`, not raw UTC.
- Do not bypass `Cache` for heavy aggregations without reason.
- Companion UI plan lives in ubuteco-react — API changes need rswag update.
