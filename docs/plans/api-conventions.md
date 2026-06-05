# API conventions

**Status:** in progress (plan [05-platform-hardening](./05-platform-hardening.md))

---

## Error responses

Prefer structured JSON over bare string arrays:

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

### Codes (initial set)

| Code | HTTP | When |
|------|------|------|
| `validation_error` | 422 | ActiveRecord / model validation |
| `insufficient_stock` | 422 | Order item stock guard |
| `rate_limit_exceeded` | 429 | Rack::Attack throttle |
| `error` | varies | Generic fallback during migration |

### Controllers

Include `ApiErrorRenderable` and use:

- `render_model_errors(record)` — validation failures
- `render_api_errors([{ code:, field:, message: }])` — domain errors

Legacy `render json: model.errors.full_messages` is migrated gradually.

### Locale

Validation `message` strings use the organization locale via `SetOrganizationRegional` (`I18n.with_locale`). Attribute labels come from `config/locales/activerecord.*.yml` (`activerecord.attributes.{model}.{field}`). The `field` key in each error is the machine name (e.g. `beer_style`) for client-side mapping.

---

## Auth (JWT)

- Issued on `POST /auth/sign_in` and registration flows via Devise JWT.
- **Expiry:** 24 hours (`config/initializers/devise.rb` → `jwt.expiration_time`).
- **Secret:** `JWT_SECRET` env (never commit).
- **Revocation:** JWT denylist on `DELETE /auth/sign_out` (`jwt.revocation_requests`).
- Refresh tokens are **not** implemented yet; clients re-authenticate after expiry.

See [dev-setup.md](../dev-setup.md) for local env vars.

---

## CORS

- **Development / test:** localhost origins for Next.js (`:3000`, `:3001`, `:4000`) plus optional `CORS_ORIGINS`.
- **Staging / production:** `CORS_ORIGINS` required (comma-separated full origins, e.g. `https://app.example.com`).

---

## Rate limits (Rack::Attack)

| Throttle | Limit | Scope |
|----------|-------|-------|
| `req/ip` | 300 / 5 min | All requests |
| `logins/ip`, `logins/email` | 5 / 20 sec | `POST /auth/sign_in` |
| `signups/ip` | 5 / 20 sec | `POST /auth/sign_up` |
| `search/ip` | 60 / 1 min | `GET /api/v1/*` with `?q=` |

429 responses use the error format with `code: rate_limit_exceeded`.
