# API conventions

## Request / response

- JSON API under `/api/v1/`
- Success: resource JSON or `{ data, meta }` for paginated index (check existing jbuilder for each controller)
- **Validation / domain errors:** `422` (or other status) with structured JSON — see [Error responses](#error-responses)
- Delete success: `204 No Content`
- Auth failure: `401`; forbidden: `403` (may include structured error body for known cases)

## Error responses

Standard shape (all v1 controllers via `ApiErrorRenderable`):

```json
{
  "errors": [
    {
      "code": "validation_error",
      "field": "email",
      "message": "Email has already been taken"
    }
  ]
}
```

| Code | HTTP | When |
|------|------|------|
| `validation_error` | 422 | ActiveRecord / model validation |
| `insufficient_stock` | 422 | Order item stock guard |
| `kitchen_closed` | 403 | Kitchen action when org is closed |
| `account_deletion_forbidden` | 403 | Non-admin self-delete |
| `role_assignment_forbidden` | 403 | Assigning `SUPER_ADMIN` |
| `rate_limit_exceeded` | 429 | Rack::Attack |
| `search_unavailable` | 503 | OpenSearch down |
| `error` | varies | Generic fallback |

Controllers: `render_model_errors(record)`, `render_api_errors([{ code:, field:, message: }])`, `render_i18n_api_error(code, ...)`.

Messages use organization locale via `SetOrganizationRegional`. Attribute labels: `config/locales/models/{model}/{locale}.yml`.

See [ADR 004](../decisions/004-structured-api-errors.md). Auth, CORS, rate limits: [plans/api-conventions.md](../plans/api-conventions.md).

## Authentication

```http
Authorization: Bearer <jwt>
Content-Type: application/json
```

Obtain token via Devise session/sign-in endpoints (see routes and swagger).

## Pagination

Index actions use Pagy; search endpoints may use Searchkick — follow existing controller patterns.

## Money fields

Typical pattern on models:

```ruby
monetize :price_cents, with_currency: :price_currency
```

In JSON you may see:

- `price_cents` + `price_currency`
- and/or nested money object from jbuilder `extract!`

Frontend helper: `ubuteco-react/src/app/_lib/money.ts` and `format.ts`.

## Organizations JSON

Partial: `app/views/api/v1/organizations/_organization.json.jbuilder`

Common fields: `id`, `name`, `phone`, `operational_status`, `logo_url`, timestamps. Regional settings (`locale`, `default_currency`, `timezone`) added by plan 02 when migrated.

## File uploads

Active Storage for attachments (e.g. org logo, avatars). URLs may appear as `logo_url`, `avatar_url` in JSON.

## Swagger / contract

- **Canonical spec:** `swagger/v1/swagger.yaml` — generated from rswag request specs (`rake rswag:specs:swaggerize`).
- **Static docs site:** `docs/swagger.yaml` is a copy for GitHub Pages Swagger UI — sync with `rake openapi:sync_docs` or `rake openapi:refresh`.
- **CI:** `rake openapi:drift_check` regenerates and fails if committed YAML differs.
- Specs: `spec/requests/api/v1/*_spec.rb` with rswag
- Schema definitions: `spec/swagger_helper.rb`
- Regenerate after API contract changes: `bundle exec rake openapi:refresh`
- See [ADR 005](../decisions/005-openapi-as-contract-source.md) and [testing.md](./testing.md)

## Idempotency / migrations

When adding columns that may already exist from `schema.rb` load (Rails 8 fresh DB), prefer idempotent migrations (`column_exists?`, `index_exists?`) or align `schema.rb` version with migration order — document in plan if non-obvious.
