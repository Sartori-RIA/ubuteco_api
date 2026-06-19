# Common AI pitfalls — ubuteco_api

Lessons from real mistakes when using agents on this codebase. Read before large changes.

## Architecture & legacy

| Pitfall | Correct approach |
|---------|------------------|
| Port patterns from Angular `ubuteco_spa` | **Abandoned.** Active UI is [ubuteco-react](../../../ubuteco-react). See [ADR 003](../decisions/003-react-only-frontend.md). |
| Propose schema-per-tenant (Apartment) | **Rejected.** Shared schema + `organization_id`. See [ADR 001](../decisions/001-shared-schema-multi-tenant.md). |
| Mix unrelated plans on one branch | One plan → `feature/<slug>` → one PR. See [workflow-plans-and-git.md](../workflow-plans-and-git.md). |

## Multi-tenant

| Pitfall | Correct approach |
|---------|------------------|
| Trust `organization_id` from client params on create | Set tenant from `Current.organization` / `current_user.organization_id` in controller strong params. |
| Rely on `default_scope` for isolation | Explicit scoping in abilities and queries. |
| Skip cross-tenant spec for new resource | Add case under `spec/security/cross_tenant/`. |
| Forget `Current` in Sidekiq jobs | Pass `organization_id` explicitly or set `Current` in job — no automatic tenant in background work. |

## API contract

| Pitfall | Correct approach |
|---------|------------------|
| Change controller JSON without updating OpenAPI | Regenerate rswag + `rake openapi:drift_check`. See [ADR 005](../decisions/005-openapi-as-contract-source.md). |
| Return bare `errors.full_messages` array | Use `ApiErrorRenderable` — `render_model_errors` / `render_api_errors`. See [ADR 004](../decisions/004-structured-api-errors.md). |
| Invent endpoint paths | Check `config/routes.rb` and `swagger/v1/swagger.yaml` first. |

## Domain logic

| Pitfall | Correct approach |
|---------|------------------|
| Put order/stock logic in controllers | Use `Orders::*`, `Kitchen::*`, `Inventory::*` services. |
| Broadcast kitchen events ad hoc | Only via `Kitchen::BroadcastOrderItem`. |
| Treat all order items like dishes | Stock-backed products vs dishes — different states. See [orders-lifecycle.md](./orders-lifecycle.md). |
| Allow mutations on closed orders | Guard at ability + AASM — items only on `open` orders. |

## Users & auth

| Pitfall | Correct approach |
|---------|------------------|
| Allow any user to self-delete | Only org `ADMIN` — see [users-and-platform.md](./users-and-platform.md). |
| Let org admin assign `SUPER_ADMIN` | Blocked in `UsersController#authorize_assignable_role!`. |

## Operations (ask first)

| Pitfall | Correct approach |
|---------|------------------|
| Run `db:migrate` / `db:drop` automatically | **Ask first** — DB may be offline. Document in plan Manual steps. |
| Commit `.env` or credentials | Never. |
| Force-push `master` | Never. |

## Process

| Pitfall | Correct approach |
|---------|------------------|
| Open PR without updating plan checkboxes | Update `docs/plans/NN-*.md` + README on same branch. |
| Skip quality gates | Run `bin/ci` or individual checks before push. |
| Large single commit | Small commits: `feat`, `test`, `docs` per logical change. |
