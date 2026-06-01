# API conventions

## Request / response

- JSON API under `/api/v1/`
- Success: resource JSON or `{ data, meta }` for paginated index (check existing jbuilder for each controller)
- Validation errors: `422` with JSON array of human-readable strings (often `errors.full_messages`)
- Delete success: `204 No Content`
- Auth failure: `401`; forbidden: `403`

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

- Specs: `spec/requests/api/v1/*_spec.rb` with rswag
- Schema definitions: `spec/swagger_helper.rb`
- Regenerate when plan 08 or feature work requires contract sync

## Idempotency / migrations

When adding columns that may already exist from `schema.rb` load (Rails 8 fresh DB), prefer idempotent migrations (`column_exists?`, `index_exists?`) or align `schema.rb` version with migration order — document in plan if non-obvious.
