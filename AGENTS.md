# AGENTS.md — ubuteco_api

Instructions for AI assistants working in this repository.

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
3. Read [docs/context/architecture.md](docs/context/architecture.md) for tenant model and request flow.
4. Read [docs/dev-setup.md](docs/dev-setup.md) for ports and local commands.

## Branching

- **Implementation** (code): one plan = one branch — `feature/<plan-slug>` (e.g. `feature/locale-and-currency`). Do not mix unrelated plans on the same branch.
- **Plan docs** (`docs/plans/`, status checkboxes, new plan files): commit **directly on `master`** — no feature branch or PR required.
- **Other docs-only** (context, ADRs, dev-setup): also fine on `master`, or `docs/<topic>` if you prefer a short-lived branch.

## Plans, commits & PRs

**Read [docs/workflow-plans-and-git.md](docs/workflow-plans-and-git.md)** before opening a PR.

- **Small commits** — one logical change each (`feat`, `fix`, `test`, `docs`, `refactor`).
- **Update the plan first** — checkboxes, `Status:` header, and `docs/plans/README.md` on the **same branch/PR** as the code (preferred).
- **One plan → one PR** when possible; complete the plan in that PR.

## Do not (unless explicitly asked)

- Run `db:migrate`, `db:drop`, or destructive DB commands — ask first; DB may be offline.
- Commit secrets (`.env`, credentials).
- Force-push to `master`.
- Add schema-per-tenant or large refactors outside the active plan scope.

## Conventions

- Tenant logic: `Current.user` / `Current.organization` — see `app/models/current.rb`.
- Org-owned records: scope by `organization_id`; never trust `organization_id` from client params on create.
- Errors: JSON array of strings, often `422` with `errors.full_messages`.
- Specs: RSpec; request specs for API; mirror patterns in `spec/controllers/api/v1/`.
- After controller/schema changes: update Swagger (`spec/swagger_helper.rb`) when the plan calls for it.

## Key paths

| Area | Path |
|------|------|
| Plans | `docs/plans/` |
| Workflow (plans, commits, PRs) | `docs/workflow-plans-and-git.md` |
| Context | `docs/context/` |
| ADRs | `docs/decisions/` |
| Tenant | `app/models/current.rb`, `app/controllers/concerns/set_current_tenant.rb` |
| Abilities | `app/models/abilities/` |
| Platform (super admin) | `app/controllers/api/v1/platform/` |

## Companion repo

Frontend plans and UI: [ubuteco-react/docs/plans](../ubuteco-react/docs/plans/README.md)
