# Plan: Organization locale & currency

**Status:** in progress  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — locale & currency](../../../ubuteco-react/docs/plans/02-locale-and-currency.md)  
**Priority:** P1  
**Depends on:** [01-multi-tenant](./01-multi-tenant.md) (recommended)  
**Estimated effort:** 1 sprint

---

## Goal

Each organization configures **locale**, **default currency**, and **timezone**. API responses and money fields respect org settings; orders snapshot currency at creation for historical accuracy.

---

## Current state

- `money-rails`: per-model `price_currency` default `"BRL"` on beers, dishes, orders, etc.
- Rails i18n: `pt-BR`, `en` locales configured in `config/initializers/i18n.rb`; not yet switched per request.
- Migration `20260601120000_add_locale_settings_to_organizations` adds `locale`, `default_currency`, `timezone` (**pending** — run `bin/rails db:migrate` when DB is available).

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

- [ ] `around_action :switch_locale` in `ApplicationController`:
  ```ruby
  I18n.with_locale(current_organization.locale) { yield }
  ```
- [ ] Fallback chain: org locale → `I18n.default_locale`
- [ ] Optional: honor `Accept-Language` only for unauthenticated or override flag (document choice)

**Acceptance:** Devise/error messages match org locale in request specs.

---

## Phase 3 — Money defaults

- [ ] Concern `OrganizationMoney` or service: `Money.default_currency = org.default_currency` per request
- [ ] On product create: default `price_currency` from org if omitted
- [ ] On order create: set `total_currency`, `discount_currency` from org
- [ ] Validation: all `order_items` on an order share compatible currency with order

**Acceptance:** new dish in USD org gets USD; order totals consistent.

---

## Phase 4 — Timezone

- [ ] `Time.use_zone(org.timezone)` in dashboard date boundaries (see [04-organization-dashboard](./04-organization-dashboard.md))
- [ ] Serialize timestamps as ISO8601 UTC; front formats with org timezone

**Acceptance:** “today’s revenue” uses org timezone, not server UTC.

---

## Phase 5 — API & authorization

- [x] `OrganizationsController#update`: permit `locale`, `default_currency`, `timezone` for ADMIN only
- [x] Operational staff read org via `fetchCurrentUser` / show organization
- [~] Swagger update

**Acceptance:** waiter cannot change locale; admin can.

---

## Phase 6 — Data migration

- [ ] Backfill existing orgs: `pt-BR`, `BRL`, `America/Sao_Paulo`
- [ ] Existing line items keep current `*_currency` columns

---

## Phase 7 — Tests

- [x] Model validations
- [x] Request: update settings (controller spec)
- [ ] Request: create order in non-default currency org (factory trait)
- [ ] I18n: one error message per locale

---

## Risks

| Risk | Mitigation |
|------|------------|
| Changing currency mid-operation | Only affect new orders; warn in UI |
| Searchkick money fields | Index numeric + currency or normalized cents |

---

## Definition of done

- [ ] Org has locale, currency, timezone
- [ ] API honors them on requests
- [ ] Orders snapshot currency
- [ ] Front settings screen (companion plan) wired

---

## References

- `config/locales/*.yml`
- `app/models/organization.rb`
- `db/schema.rb` — `*_currency` columns
