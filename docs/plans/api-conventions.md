# API conventions

**Status:** in progress (plan [05-platform-hardening](./05-platform-hardening.md))

> **Stable reference:** error format, Swagger workflow, and request patterns live in [docs/context/api-conventions.md](../context/api-conventions.md), [ADR 004](../decisions/004-structured-api-errors.md), and [ADR 005](../decisions/005-openapi-as-contract-source.md). This file tracks hardening items still in flight.

---

## Error responses

See [context/api-conventions.md](../context/api-conventions.md#error-responses) and [ADR 004](../decisions/004-structured-api-errors.md).

Legacy `render json: model.errors.full_messages` is migrated gradually (plan 05).

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
