# Plan: Multi-tenant by organization

**Status:** in progress (Phase 1–2 started)  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — multi-tenant](../../../ubuteco-react/docs/plans/01-multi-tenant.md)  
**Priority:** P0 — do before plans, dashboard, and billing  
**Estimated effort:** 1–2 sprints

---

## Architecture decision (approved)

**We will implement shared-schema multi-tenancy:**

| Layer | Approach |
|-------|----------|
| **Data** | Single PostgreSQL schema; tenant column `organization_id` on org-owned tables |
| **Request context** | `Current.organization` / `Current.user` (`ActiveSupport::CurrentAttributes`) |
| **Authorization** | CanCanCan abilities + explicit query scoping (no global `default_scope`) |
| **Search / realtime** | OpenSearch and AnyCable filtered by `organization_id` (existing pattern) |

This is the **chosen direction** for uButeco. Do not start a schema-per-tenant migration unless the triggers in [Alternatives considered](#alternatives-considered-schema-per-tenant) apply and this decision is revisited explicitly.

---

## Goal

Make **Organization** the single tenant boundary: every business read/write is scoped to the authenticated user’s organization (except explicit super-admin platform routes). Eliminate IDOR via `organization_id` in request params.

---

## Current state

- Most models have `organization_id` (orders, menu, tables, users, etc.).
- CanCanCan abilities filter by `user.organization_id` per role.
- Searchkick uses `SearchkickAuthorizable` with ability conditions.
- Kitchen cable streams: `kitchens_{organization_id}`.
- Gaps:
  - No request-level tenant context (`Current.organization`).
  - Some controllers accept `organization_id` from params (e.g. `OrdersController#create`).
  - No systematic cross-tenant request specs.
  - `SUPER_ADMIN` crosses orgs without a dedicated API namespace.

---

## Out of scope (this plan)

- Subscription plans / billing limits.
- Separate “account” above organization (franchise/holding).
- **Schema-per-tenant** (PostgreSQL schema per organization) — rejected for now; see [Alternatives considered](#alternatives-considered-schema-per-tenant).
- PostgreSQL Row Level Security (RLS) — optional hardening later; not part of the initial rollout.

---

## Alternatives considered: schema-per-tenant

Some multi-tenant systems give **each tenant its own PostgreSQL schema** (e.g. via `ros-apartment` / `apartment`), switching `search_path` per request instead of relying on `WHERE organization_id = ?`.

### Why we are not choosing it (for uButeco)

| Factor | Shared schema + `organization_id` + `Current` | Schema per tenant |
|--------|-----------------------------------------------|-------------------|
| Fit with current codebase | **High** — models, migrations, and abilities already use `organization_id` | **Low** — large rewrite |
| Migrations / CI | One schema, standard Rails flow | Run or manage migrations across N schemas |
| Shared global data | `beer_styles`, `wine_styles`, `roles` stay in one place | Duplicate or split “public” vs tenant schemas |
| Super admin / cross-org | Natural with platform routes + `organization_id` | Schema switching or multi-schema aggregation |
| Sidekiq, AnyCable, Searchkick | Already aligned with org-scoped filters | Reconfigure jobs, RPC, and indexing per tenant |
| Isolation strength | Good with discipline + tests; RLS can add a DB layer later | Stronger default isolation |
| Typical SaaS scale (many small/medium orgs) | **Standard choice** | Usually for legal isolation or very large single tenants |

### Important distinction

**`Current` is not an alternative to schema-per-tenant.** They solve different problems:

- **`Current.organization`** — which tenant is active **in this request/job** (required in both models).
- **Schema-per-tenant** — **where rows live** in PostgreSQL.

Even with one schema per org, you still need a “current tenant” to pick the schema (subdomain, JWT, header, etc.).

### When to revisit this decision

Re-open schema-per-tenant only if one or more become true:

- Legal/compliance requires **physical** separation of tenant data.
- A single organization needs **dedicated DB capacity** (shard-sized tenant).
- Frequent **per-tenant backup/restore/export** at scale where row-level export is insufficient.
- Repeated incidents of **cross-tenant data leaks** that RLS + tests cannot mitigate.

Until then, implement the phases below on the **shared schema** model.

### Optional future hardening (still shared schema)

If isolation requirements tighten without a full schema migration:

- PostgreSQL **RLS** policies keyed off `current_setting('app.organization_id')` set from `Current` at the start of each request.
- Documented in a follow-up plan; **not** a blocker for Phases 1–6.

---

## Phase 1 — Tenant context

- [x] Add `app/models/current.rb` (ActiveSupport::CurrentAttributes):
  - `organization`, `user`, `organization_id`
- [x] Set in `ApplicationController` via `SetCurrentTenant` after `authenticate_user!`:
  - `Current.user = current_user`
  - `Current.organization = current_user.organization` (403 if missing for org-scoped roles)
- [x] Clear `Current` in `after_action` (`SetCurrentTenant#reset_current_tenant`)
- [ ] Document: console/jobs must set `Current` or pass `organization_id` explicitly

**Acceptance:** request specs assert `Current.organization_id` matches user’s org.

---

## Phase 2 — Stop trusting client `organization_id`

- [x] Audit all controllers for `params[:organization_id]` and `permit(:organization_id)`
- [x] **OrdersController** — always assign user's org; staff cannot pass foreign id
- [x] **UsersController** — removed `:organization_id` from permitted list
- [x] **ThemesController** — fixed merge bug; org id from server only
- [ ] **Create flows:** products controllers — already force org on create (verify only)
- [ ] Add RuboCop custom cop or grep in CI checklist (optional)

**Acceptance:** no org-scoped create/update accepts foreign `organization_id` from a normal admin/waiter.

---

## Phase 3 — Query scoping

- [x] Add concern `OrganizationScoped` (no global `default_scope`)
- [x] Org-owned models include `OrganizationScoped` + `OrganizationReindexable`
- [x] `KitchensController` uses `Current.organization`
- [x] `ReindexJob` scoped by `organization_id`

**Acceptance:** index/search never returns records from another org.

---

## Phase 4 — Super admin separation

- [x] Platform routes: `/api/v1/platform/organizations` (+ nested users index)
- [x] `SuperAdminAbility` split: platform vs catalog-read on org routes
- [x] No cross-org read on orders/users via org-scoped routes

**Acceptance:** super admin cannot hit `/api/v1/orders` for org B while “thinking” they’re in org A without explicit platform API.

---

## Phase 5 — Real-time & jobs

- [x] `KitchenChannel` spec: org stream only; reject without org
- [x] `ReindexJob` sets/clears `Current` per job
- [x] `KitchenCableBroadcaster` logs `organization_id`

**Acceptance:** cable + jobs documented for tenant propagation.

---

## Phase 6 — Database & tests

- [x] Composite indexes on `orders (organization_id, status/created_at)`
- [x] Cross-tenant spec pack: orders, dishes, users, kitchen queue
- [x] Platform organizations request specs
- [x] Swagger `new_order` has no `organization_id` (already empty)

**Acceptance:** CI runs cross-tenant examples; all green.

---

## Risks

| Risk | Mitigation |
|------|------------|
| Breaking clients sending `organization_id` | Deprecate in API docs; ignore param in backend |
| Jobs without tenant | Job base class requiring `organization_id` |
| Super admin workflows | Platform namespace + separate UI later |

---

## Definition of done

- [x] `Current.organization` used in org-scoped controllers/services (kitchen, orders create)
- [x] Zero IDOR on `organization_id` param for org roles
- [x] Cross-tenant spec suite added
- [~] README/plans updated; Swagger aligned

---

## References

- `app/models/abilities/*`
- `app/controllers/concerns/searchkick_authorizable.rb`
- `app/channels/kitchen_channel.rb`
- Architecture: [docs/system-architecture.png](../system-architecture.png)
