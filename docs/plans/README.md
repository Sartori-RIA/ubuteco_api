# Backend improvement plans

Structured plans for uButeco API (`ubuteco_api`). Each document is self-contained: goals, current state, phases, acceptance criteria, and links to the React companion when the front is involved.

**AI assistants:** read [AGENTS.md](../../AGENTS.md) first (includes [workflow-plans-and-git.md](../workflow-plans-and-git.md) — canonical for all agents), then [docs/context/](../context/) for stable architecture. New plans: copy [TEMPLATE.md](./TEMPLATE.md).

**Workflow:** updating plans or backlog entries → commit on **`master`** (no PR). Code for a plan → `feature/<slug>` branch. **Before PR:** update plan status on the branch; **small commits** — see [workflow-plans-and-git.md](../workflow-plans-and-git.md).

**Active frontend:** [ubuteco-react](../../../ubuteco-react) only. Angular `ubuteco_spa` is abandoned — no SPA migration or parity plans.

**Multi-tenant decision (approved):** shared PostgreSQL schema + `organization_id` + `Current` — not schema-per-tenant. See [01-multi-tenant.md](./01-multi-tenant.md#architecture-decision-approved).

**Subscription / billing:** [03 Subscription plans](./03-subscription-plans.md) is **last** — implement only after all other feature plans and meaningful progress on [05 Platform hardening](./05-platform-hardening.md). Do not start billing before the core product surface is stable.

## Tracking

| Layer | Purpose |
|-------|---------|
| **Plan doc** (`docs/plans/`) | Spec, phases, checkboxes — source of truth for scope |
| **Status column (below)** | High-level progress at a glance |
| **GitHub Issue** | Discussion, assignee, link PRs (`Closes #N`) |
| **GitHub Project** | Pipeline columns (Backlog → In progress → In review → Done) |

When a plan gets an issue, add `**GitHub:** owner/repo#NN` to the plan header (see [TEMPLATE.md](./TEMPLATE.md)).

**Plan status values:** `not started` · `in progress` · `completed`

**Task checkboxes inside plans:** `[ ]` not started · `[~]` in progress · `[x]` done

## Suggested implementation order

Ordered by priority. **#3 is deferred to the end** (see note above).

| # | Plan | Status | Priority | Depends on |
|---|------|--------|----------|------------|
| 1 | [Multi-tenant](./01-multi-tenant.md) | completed | P0 | — |
| 2 | [Locale & currency](./02-locale-and-currency.md) | completed | P1 | #1 |
| 10 | [Users admin API](./10-users-admin-api.md) | completed | P1 | #1 |
| 6 | [Order lifecycle](./06-order-lifecycle.md) | completed | P1 | #1 |
| 4 | [Organization dashboard](./04-organization-dashboard.md) | completed | P1 | #1, #2 |
| 9 | [Inventory & stock](./09-inventory-stock.md) | completed | P2 | #6 |
| 7 | [Search / OpenSearch ops](./07-search-operations.md) | completed | P2 | #1 |
| 8 | [API contract & CI/CD](./08-api-contract-and-ci.md) | completed | P2 | — |
| 5 | [Platform hardening](./05-platform-hardening.md) | in progress | Ongoing | all |
| 3 | [Subscription plans](./03-subscription-plans.md) | not started | **Last** | #1, #5 |

## Recent merges (Jun 2026)

| Plan | PR | Notes |
|------|-----|-------|
| [10 Users admin API](./10-users-admin-api.md) | [#44](https://github.com/Sartori-RIA/ubuteco_api/pull/44) | Self-delete policy, SUPER_ADMIN role guard, structured errors |
| [09 Inventory & stock](./09-inventory-stock.md) | [#42](https://github.com/Sartori-RIA/ubuteco_api/pull/42) | Stock adjust, low stock, `stock_movements` audit |
| [02 Locale & currency](./02-locale-and-currency.md) | [#43](https://github.com/Sartori-RIA/ubuteco_api/pull/43) | Locales `en-CA`, `fr-CA`, `fr`; fallbacks for API messages |

**In progress:** [05 Platform hardening](./05-platform-hardening.md).

**Next up:** [10 Document titles](../../../ubuteco-react/docs/plans/10-document-titles.md), [09 Frontend performance](../../../ubuteco-react/docs/plans/09-frontend-performance.md). **Last:** [03 Subscription plans](./03-subscription-plans.md).

Frontend companions: [ubuteco-react/docs/plans](../../../ubuteco-react/docs/plans/README.md).

When starting a plan, update its header `Status:` and check boxes as you go. Use branch `feature/<plan-slug>` (one plan per branch).

## Also see

| Doc | Purpose |
|-----|---------|
| [context/](../context/) | Architecture, roles, API conventions |
| [decisions/](../decisions/) | ADRs (permanent decisions) |
| [dev-setup.md](../dev-setup.md) | Ports, docker, migrations |
