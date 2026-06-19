# Architecture — API

Stable reference for how ubuteco_api is structured. For active work items, see [plans/README.md](../plans/README.md).

## Multi-tenant model

**Shared PostgreSQL schema** with `organization_id` on org-owned tables. Not schema-per-tenant.

| Concept | Implementation |
|---------|----------------|
| Tenant | `Organization` |
| Request context | `Current.user`, `Current.organization` (`ActiveSupport::CurrentAttributes`) |
| Set on each request | `SetCurrentTenant` concern on `ApplicationController` |
| Authorization | CanCanCan abilities under `app/models/abilities/` |
| Search | Searchkick + org filters via `SearchkickAuthorizable` |
| Real-time | AnyCable streams keyed by org (e.g. kitchen) |

Jobs and console **must** set `Current` explicitly or pass `organization_id` — there is no automatic tenant in Sidekiq. See [ADR 006](../decisions/006-jobs-and-current-tenant.md).

## API surface

- Base path: `/api/v1/`
- Auth: `Authorization: Bearer <JWT>` (Devise JWT)
- Platform (cross-org, super admin): `/api/v1/platform/...`
- Org-scoped resources: `/api/v1/organizations`, `/api/v1/orders`, menu entities, etc.

## Roles (summary)

| Role | Scope |
|------|--------|
| `SUPER_ADMIN` | Platform; read catalog cross-org; limited mutation |
| `ADMIN` | Full org admin |
| `KITCHEN` | Kitchen queue |
| `WAITER` | Orders / floor |
| `CASH_REGISTER` | Register operations |
| `CUSTOMER` | End customer (limited) |

Details: [roles-and-access.md](./roles-and-access.md)

## Money

- money-rails: `*_cents` integer columns + `*_currency` string (ISO 4217)
- Default currency in DB is often `BRL` at column level; org-level default currency is planned in [02-locale-and-currency](../plans/02-locale-and-currency.md)
- JSON: jbuilder may expose cents fields and/or serialized money objects — see [api-conventions.md](./api-conventions.md)

## Key files

```
app/models/current.rb
app/controllers/concerns/set_current_tenant.rb
app/controllers/application_controller.rb
app/models/abilities/
config/routes.rb
```

## Related decisions

- [001-shared-schema-multi-tenant.md](../decisions/001-shared-schema-multi-tenant.md)
- [003-react-only-frontend.md](../decisions/003-react-only-frontend.md)
- [004-structured-api-errors.md](../decisions/004-structured-api-errors.md)
- [005-openapi-as-contract-source.md](../decisions/005-openapi-as-contract-source.md)
- [006-jobs-and-current-tenant.md](../decisions/006-jobs-and-current-tenant.md)

## Domain context (for feature work)

| Domain | Doc |
|--------|-----|
| Orders & kitchen | [orders-lifecycle.md](./orders-lifecycle.md) |
| Users & platform admin | [users-and-platform.md](./users-and-platform.md) |
| Inventory & stock | [inventory-stock.md](./inventory-stock.md) |
| Search & OpenSearch | [search-and-opensearch.md](./search-and-opensearch.md) |
| Dashboard | [dashboard.md](./dashboard.md) |
| i18n & money | [i18n-and-money.md](./i18n-and-money.md) |
| API conventions | [api-conventions.md](./api-conventions.md) |
| Roles summary | [roles-and-access.md](./roles-and-access.md) |
| Testing | [testing.md](./testing.md) |
| AI pitfalls | [common-ai-pitfalls.md](./common-ai-pitfalls.md) |
