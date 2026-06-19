# ADR 004: Structured API error responses

**Status:** Accepted  
**Date:** 2026 (documented from plan 05 / #39)

## Context

Clients and the React frontend need stable error handling. Legacy responses used bare JSON string arrays (`errors.full_messages`), which are hard to map to fields and i18n.

## Decision

All v1 API controllers use **`ApiErrorRenderable`** (included on `ApplicationController`):

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

- `render_model_errors(record)` — ActiveRecord validation failures (`code: validation_error`)
- `render_api_errors([{ code:, field:, message: }])` — domain errors
- `render_i18n_api_error(code, status:, **options)` — localized messages from `config/locales/api/*.yml`

Known codes include: `validation_error`, `insufficient_stock`, `kitchen_closed`, `account_deletion_forbidden`, `role_assignment_forbidden`, `rate_limit_exceeded`, `search_unavailable`, `error` (fallback).

Legacy string-array responses are **not** added to new code.

## Consequences

- rswag uses `#/components/schemas/errors_response` for 422/403 error examples.
- OpenAPI and frontend can key off `code` and optional `field`.
- Migration of any remaining legacy renders is tracked in [plan 05](../plans/05-platform-hardening.md).

## References

- `app/controllers/concerns/api_error_renderable.rb`
- [docs/context/api-conventions.md](../context/api-conventions.md)
- [docs/plans/api-conventions.md](../plans/api-conventions.md) (auth, CORS, rate limits)
