# AGENTS.md — ubuteco_api

Instructions for AI assistants working in this repository.

**Also:** [CLAUDE.md](CLAUDE.md) (Claude Code) · [.github/copilot-instructions.md](.github/copilot-instructions.md) (GitHub Copilot) — both point here.

## Stack

- Ruby 4 / Rails 8.1 API-only
- PostgreSQL, Redis, Sidekiq, Searchkick + OpenSearch, AnyCable
- Auth: Devise + JWT (`allowlisted_jwts`)
- Authorization: CanCanCan
- Money: money-rails (amounts as cents + ISO currency columns)

## Active frontend

**[ubuteco-react](../ubuteco-react)** is the only active UI. Angular `ubuteco_spa` is abandoned — do not port or reference it.

## Before you code

1. Read [docs/plans/README.md](docs/plans/README.md) — pick **one plan**, check status and dependencies.
2. Read [docs/workflow-plans-and-git.md](docs/workflow-plans-and-git.md) — small commits, update plan before PR (**canonical** for all agents; not only Cursor).
3. Read [docs/context/common-ai-pitfalls.md](docs/context/common-ai-pitfalls.md) — frequent agent mistakes in this repo.
4. Small API bugs / polish: [docs/backlog/README.md](docs/backlog/README.md) — promote to a plan if scope grows.
5. Read [docs/context/architecture.md](docs/context/architecture.md) for tenant model and request flow.
6. Read domain context for your plan area — see [Key paths](#key-paths).
7. Read [docs/dev-setup.md](docs/dev-setup.md) for ports and local commands.

## Branching

- **Implementation** (code): one plan = one branch — `feature/<plan-slug>` (e.g. `feature/locale-and-currency`). Do not mix unrelated plans on the same branch.
- **Plan docs** (`docs/plans/`, status checkboxes, new plan files): commit **directly on `master`** — no feature branch or PR required.
- **Backlog docs** (`docs/backlog/`): commit **directly on `master`** when text-only.
- **Other docs-only** (context, ADRs, dev-setup): also fine on `master`, or `docs/<topic>` if you prefer a short-lived branch.

## Plans, commits & PRs

**Read [docs/workflow-plans-and-git.md](docs/workflow-plans-and-git.md)** before opening a PR.

- **Small commits** — one logical change each (`feat`, `fix`, `test`, `docs`, `refactor`).
- **Update the plan first** — checkboxes, `Status:` header, and `docs/plans/README.md` on the **same branch/PR** as the code (preferred).
- **One plan → one PR** when possible; complete the plan in that PR.
- **Quality gates before PR** — `bin/rubocop`, `bundle exec rspec` (coverage), `bin/brakeman`, `bin/bundler-audit`; see workflow doc §4.

## Do not (unless explicitly asked)

- Run `db:migrate`, `db:drop`, or destructive DB commands — ask first; DB may be offline.
- Commit secrets (`.env`, credentials).
- Force-push to `master`.
- Add schema-per-tenant or large refactors outside the active plan scope.

## Conventions

- Tenant logic: `Current.user` / `Current.organization` — see `app/models/current.rb`.
- Org-owned records: scope by `organization_id`; never trust `organization_id` from client params on create.
- Errors: structured JSON via `ApiErrorRenderable` — `{ errors: [{ code, field?, message }] }`. Use `render_model_errors` / `render_api_errors`. See [docs/context/api-conventions.md](docs/context/api-conventions.md) and [ADR 004](docs/decisions/004-structured-api-errors.md).
- Specs: RSpec; request specs for API; cross-tenant cases required for org-scoped resources. See [docs/context/testing.md](docs/context/testing.md).
- After controller/schema changes: update rswag + run `openapi:drift_check` when the contract changes — [ADR 005](docs/decisions/005-openapi-as-contract-source.md).

## Key paths

| Area | Path |
|------|------|
| Plans | `docs/plans/` |
| Backlog | `docs/backlog/` |
| Workflow (plans, commits, PRs) | `docs/workflow-plans-and-git.md` |
| AI pitfalls | `docs/context/common-ai-pitfalls.md` |
| Context (stable) | `docs/context/` |
| Orders & kitchen | `docs/context/orders-lifecycle.md` |
| Users & platform | `docs/context/users-and-platform.md` |
| Inventory & stock | `docs/context/inventory-stock.md` |
| Search & OpenSearch | `docs/context/search-and-opensearch.md` |
| Dashboard | `docs/context/dashboard.md` |
| i18n & money | `docs/context/i18n-and-money.md` |
| Testing patterns | `docs/context/testing.md` |
| ADRs | `docs/decisions/` |
| OpenAPI (canonical) | `swagger/v1/swagger.yaml` |
| Tenant | `app/models/current.rb`, `app/controllers/concerns/set_current_tenant.rb` |
| Abilities | `app/models/abilities/` |
| Platform (super admin) | `app/controllers/api/v1/platform/` |

## Companion repo

Frontend plans and UI: [ubuteco-react/docs/plans](../ubuteco-react/docs/plans/README.md)
