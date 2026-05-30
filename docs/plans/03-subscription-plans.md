# Plan: Subscription plans (SaaS)

**Status:** not started  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — subscription plans](../../../ubuteco-react/docs/plans/03-subscription-plans.md)  
**Priority:** P2  
**Depends on:** [01-multi-tenant](./01-multi-tenant.md)  
**Estimated effort:** 2–3 sprints (without payment provider); +1 sprint for Stripe/webhooks

---

## Goal

Organizations subscribe to **plans** with defined limits and feature flags. Enforce limits in API; prepare for external billing (Stripe/Paddle) without coupling domain logic to the gateway.

---

## Current state

- No `plans`, `subscriptions`, or feature flags.
- All orgs have full feature access implicitly.

---

## Product decisions (lock before coding)

| Decision | Recommendation |
|----------|----------------|
| Billing provider | Stripe Billing (or defer: manual plan assignment in v1) |
| Limit types v1 | `max_users`, `max_tables`, features: `kitchen`, `search`, `dashboard` |
| Trial | 14-day `trialing` status, job to downgrade |
| Grace period | 3 days `past_due` before read-only mode |

---

## Phase 1 — Domain model

- [ ] Migration:
  ```ruby
  # plans
  t.string :name, :slug, null: false
  t.jsonb :limits, default: {}, null: false   # max_users, max_tables, features: {}
  t.integer :price_cents
  t.string :price_currency, default: "BRL"
  t.string :billing_interval  # month, year

  # subscriptions
  t.references :organization, null: false, index: { unique: true }
  t.references :plan, null: false
  t.string :status  # trialing, active, past_due, canceled
  t.datetime :current_period_end
  t.string :external_customer_id
  t.string :external_subscription_id
  ```
- [ ] Models: `Plan`, `Subscription`, `Organization has_one :subscription`
- [ ] Seeds: `free`, `starter`, `pro` plans with sensible limits

**Acceptance:** every org gets default `free` subscription on create (callback or seed task).

---

## Phase 2 — Feature & limit service

- [ ] `Organizations::Entitlements` (or `PlanEnforcement`):
  - `feature?(org, :kitchen) -> boolean`
  - `within_limit?(org, :users) -> boolean`
  - `usage(org, :users) -> integer`
- [ ] Single entry point for controllers/services — no scattered checks

**Acceptance:** unit tests per plan/limit combination.

---

## Phase 3 — Enforcement points

- [ ] `UsersController#create` — check `max_users`
- [ ] `TablesController#create` — check `max_tables`
- [ ] `KitchensController` / cable — check `feature?(:kitchen)`
- [ ] Search endpoints — check `feature?(:search)` if gated
- [ ] Return `402 Payment Required` or `403` with `{ code: "plan_limit", limit: "max_users" }`

**Acceptance:** free plan blocks excess users with structured error.

---

## Phase 4 — API surface (org admin)

- [ ] `GET /api/v1/organizations/:id/subscription` — current plan, usage, period_end
- [ ] `GET /api/v1/plans` — public plan list (marketing tiers)
- [ ] Super admin: `PATCH /api/v1/platform/organizations/:id/subscription` — manual plan change (v1 without Stripe)

**Acceptance:** admin sees plan + usage in API JSON.

---

## Phase 5 — Billing integration (optional phase)

- [ ] Stripe Customer on org registration
- [ ] Checkout session endpoint
- [ ] Webhook controller (`invoice.paid`, `customer.subscription.updated`, …)
- [ ] Idempotent webhook handling (store event ids)
- [ ] Map Stripe price ids → `Plan` records

**Acceptance:** test mode subscription activates plan on webhook.

---

## Phase 6 — Background jobs

- [ ] Daily job: expire `trialing` → downgrade or `past_due`
- [ ] Notify admin (mail) before trial end (needs mailer)

---

## Phase 7 — Tests & docs

- [ ] Model + service specs
- [ ] Request specs: limit exceeded, feature disabled
- [ ] Swagger for subscription endpoints
- [ ] Update architecture doc if billing service added

---

## Risks

| Risk | Mitigation |
|------|------------|
| Grandfathering existing orgs | Migration assigns `pro` or unlimited legacy plan |
| Kitchen suddenly disabled | Feature flag + UI banner before enforce |

---

## Definition of done (MVP without Stripe)

- [ ] Plans + subscriptions in DB
- [ ] Entitlements service enforced on create actions
- [ ] Org admin can read subscription
- [ ] Super admin can assign plan manually

---

## Definition of done (with billing)

- [ ] Stripe checkout + webhooks update subscription status
- [ ] Cancel/upgrade flows documented

---

## References

- [01-multi-tenant](./01-multi-tenant.md) — platform routes for super admin
- [04-organization-dashboard](./04-organization-dashboard.md) — may gate `feature?(:dashboard)`
