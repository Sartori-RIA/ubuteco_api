# Plan: Organization locale & currency

**Status:** completed  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — locale & currency](../../../ubuteco-react/docs/plans/02-locale-and-currency.md)  
**Branch:** `feature/locale-and-currency` (merged — PR #32)

---

## Goal

Each organization configures **locale**, **default currency**, and **timezone**. API responses and money fields respect org settings; orders snapshot currency at creation for historical accuracy.

---

## Current state

- `money-rails`: per-model `price_currency`; org default applied per request via `SetOrganizationRegional`.
- Rails i18n: `pt-BR`, `en`, `es`, `en-CA`, `fr`, `fr-CA` in `config/initializers/i18n.rb`; switched per request via `SetOrganizationRegional`.
- Migration `20260601120000_add_locale_settings_to_organizations` applied — `locale`, `default_currency`, `timezone` on `organizations`.

---

## Product decisions (lock before coding)

| Decision | Recommendation |
|----------|----------------|
| Source of truth for UI language | **Organization** (not per-user) in v1 |
| Menu item names | User-entered; no auto-translation in v1 |
| Currency on open order | Single currency per order; reject mixed line items |
| Historical orders | Freeze `total_currency` / line currencies at order `created_at` |

---

## Phase 1 — Schema & model

- [x] Migration `organizations`:
  ```ruby
  t.string :locale, default: "pt-BR", null: false
  t.string :default_currency, default: "BRL", null: false  # ISO 4217
  t.string :timezone, default: "America/Sao_Paulo", null: false
  ```
- [x] Validations: `locale` in `I18n.available_locales`; currency in `Money::Currency` table; timezone in `ActiveSupport::TimeZone`
- [x] Expose in organization JSON partial (read + update for admin)

**Acceptance:** admin can PATCH org settings; invalid locale/currency rejected.

---

## Phase 2 — Request locale

- [x] `SetOrganizationRegional` concern on `ApplicationController` (`I18n.with_locale` + fallbacks)
- [x] Fallback chain: org locale → `I18n.default_locale`
- [x] Attribute labels: `config/locales/models/{resource}/{locale}.yml` (`en`, `pt-BR`, `es`)
- [x] v1: ignore `Accept-Language`; org locale only (see [ADR 002](../decisions/002-org-locale-not-user-locale.md))

**Acceptance:** validation errors match org locale in request specs.

---

## Phase 3 — Money defaults

- [x] `Money.with_currency(org.default_currency)` per request in `SetOrganizationRegional`
- [x] On product create: default `price_currency` from org when omitted (via request-scoped `Money.default_currency`)
- [x] On order create: set `total_currency`, `discount_currency`, `total_with_discount_currency` from org
- [x] Validation: `order_items` currency must match order on create

**Acceptance:** new product in USD org gets USD; order totals consistent.

---

## Phase 4 — Timezone

- [x] `Time.use_zone(org.timezone)` per request in `SetOrganizationRegional`
- [ ] Dashboard date boundaries (see [04-organization-dashboard](./04-organization-dashboard.md))
- [x] Serialize timestamps as ISO8601 UTC; front formats with org timezone

**Acceptance:** “today’s revenue” uses org timezone, not server UTC — dashboard deferred to plan 04.

---

## Phase 5 — API & authorization

- [x] `OrganizationsController#update`: permit `locale`, `default_currency`, `timezone` for ADMIN only
- [x] Operational staff read org via `fetchCurrentUser` / show organization
- [x] Swagger update

**Acceptance:** waiter cannot change locale; admin can.

---

## Phase 6 — Data migration

- [x] Column defaults backfill new rows: `pt-BR`, `BRL`, `America/Sao_Paulo` (via migration defaults)
- [x] Existing line items keep current `*_currency` columns

---

## Phase 7 — Tests

- [x] Model validations
- [x] Request: update settings, waiter blocked from locale change
- [x] Request: create order in USD org (factory trait)
- [x] I18n: validation error message per locale
- [x] Order item mixed-currency rejection

---

## Risks

| Risk | Mitigation |
|------|------------|
| Changing currency mid-operation | Only affect new orders; warn in UI |
| Searchkick money fields | Index numeric + currency or normalized cents |

---

## Definition of done

- [x] Org has locale, currency, timezone (after migration)
- [x] API honors them on requests
- [x] Orders snapshot currency
- [x] Front settings screen (companion plan) wired

---

## Follow-up (not blocking)

- [ ] Dashboard date boundaries using org timezone — see [04-organization-dashboard](./04-organization-dashboard.md)

---

## Also shipped (post–PR #32)

- [x] Locales `en-CA`, `fr-CA`, `fr` with i18n fallbacks — PR [#43](https://github.com/Sartori-RIA/ubuteco_api/pull/43)

---

## References

- `config/locales/*.yml`
- `app/models/organization.rb`
- `app/controllers/concerns/set_organization_regional.rb`
- `db/schema.rb` — `*_currency` columns
