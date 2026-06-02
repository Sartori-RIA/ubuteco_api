# Backend improvement plans

Structured plans for uButeco API (`ubuteco_api`). Each document is self-contained: goals, current state, phases, acceptance criteria, and links to the React companion when the front is involved.

**AI assistants:** read [AGENTS.md](../../AGENTS.md) first, then [docs/context/](../context/) for stable architecture. New plans: copy [TEMPLATE.md](./TEMPLATE.md).

**Active frontend:** [ubuteco-react](../../../ubuteco-react) only. Angular `ubuteco_spa` is abandoned — no SPA migration or parity plans.

**Multi-tenant decision (approved):** shared PostgreSQL schema + `organization_id` + `Current` — not schema-per-tenant. See [01-multi-tenant.md](./01-multi-tenant.md#architecture-decision-approved).

## Suggested implementation order

| # | Plan | Priority | Depends on |
|---|------|----------|------------|
| 1 | [Multi-tenant](./01-multi-tenant.md) | P0 | — |
| 2 | [Locale & currency](./02-locale-and-currency.md) | P1 | #1 |
| 10 | [Users admin API](./10-users-admin-api.md) | P1 | #1 |
| 6 | [Order lifecycle](./06-order-lifecycle.md) | P1 | #1 |
| 4 | [Organization dashboard](./04-organization-dashboard.md) | P1 | #1, #2 |
| 7 | [Search / OpenSearch ops](./07-search-operations.md) | P2 | #1 |
| 8 | [API contract & CI/CD](./08-api-contract-and-ci.md) | P2 | — |
| 9 | [Inventory & stock](./09-inventory-stock.md) | P2 | #6 |
| 3 | [Subscription plans](./03-subscription-plans.md) | P2 | #1 |
| 5 | [Platform hardening](./05-platform-hardening.md) | Ongoing | all |

Frontend companions: [ubuteco-react/docs/plans](../../../ubuteco-react/docs/plans/README.md) — org/users UI, settings deletion, testing, performance.

**Status legend:** `[ ]` not started · `[~]` in progress · `[x]` done

When starting a plan, update its header `Status:` and check boxes as you go. Use branch `feature/<plan-slug>` (one plan per branch).

## Also see

| Doc | Purpose |
|-----|---------|
| [context/](../context/) | Architecture, roles, API conventions |
| [decisions/](../decisions/) | ADRs (permanent decisions) |
| [dev-setup.md](../dev-setup.md) | Ports, docker, migrations |
