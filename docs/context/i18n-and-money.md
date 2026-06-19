# i18n, locale & money

Stable reference for regional settings. Plan: [02-locale-and-currency](../plans/02-locale-and-currency.md). Decision: [ADR 002](../decisions/002-org-locale-not-user-locale.md).

## Source of truth (v1)

**Organization** columns (not per-user):

| Column | Example | Purpose |
|--------|---------|---------|
| `locale` | `pt-BR`, `en`, `es`, `en-CA`, `fr`, `fr-CA` | API error messages, attribute labels |
| `default_currency` | `BRL`, `USD`, `CAD` | ISO 4217 — money defaults |
| `timezone` | `America/Sao_Paulo` | Request time zone |

Configured in org settings; **admin-only** PATCH on organization.

## Request-scoped behaviour

`SetOrganizationRegional` on `ApplicationController` (around_action):

```ruby
I18n.with_locale(org.locale) do
  Money.with_currency(org.default_currency) do
    Time.use_zone(org.timezone) { yield }
  end
end
```

- v1: **ignore `Accept-Language`** — org locale only.
- Fallback: org locale → `I18n.default_locale`.

## Money (money-rails)

- Columns: `*_cents` (integer) + `*_currency` (string).
- New products: default `price_currency` from org when omitted.
- New orders: snapshot `total_currency`, line currencies at creation — **historical orders keep frozen currency**.
- Validation: order line currencies must match order on create.

JSON may expose cents + currency and/or nested money from jbuilder.

## i18n files

| Area | Path |
|------|------|
| API error codes | `config/locales/api/{locale}.yml` |
| Model attribute labels | `config/locales/models/{model}/{locale}.yml` |
| Available locales | `config/initializers/i18n.rb` |

Structured errors use `field` as machine name; `message` is localized via org locale.

## Dashboard & timestamps

- API serializes timestamps as **ISO8601 UTC**.
- Dashboard date boundaries use org timezone — see [dashboard.md](./dashboard.md).
- Front formats display using org settings from API.

## Key files

```
app/controllers/concerns/set_organization_regional.rb
app/models/organization.rb
config/locales/
```

## AI pitfalls

- Do not hardcode `BRL` or `pt-BR` in new code paths.
- Do not add per-user locale without revisiting ADR 002.
- Do not mix currencies on a single order.
- Error messages: use `render_model_errors` / `render_i18n_api_error`, not hardcoded English strings in controllers.
