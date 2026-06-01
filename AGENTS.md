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
2. Read [docs/context/architecture.md](docs/context/architecture.md) for tenant model and request flow.
3. Read [docs/dev-setup.md](docs/dev-setup.md) for ports and local commands.

## Branching

- **One plan = one branch:** `feature/<plan-slug>` (e.g. `feature/locale-and-currency`).
- Do not mix unrelated plans on the same branch.
- Docs-only changes: `docs/<topic>` (e.g. `docs/ai-context`).

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
| Context | `docs/context/` |
| ADRs | `docs/decisions/` |
| Tenant | `app/models/current.rb`, `app/controllers/concerns/set_current_tenant.rb` |
| Abilities | `app/models/abilities/` |
| Platform (super admin) | `app/controllers/api/v1/platform/` |

## Companion repo

Frontend plans and UI: [ubuteco-react/docs/plans](../ubuteco-react/docs/plans/README.md)
