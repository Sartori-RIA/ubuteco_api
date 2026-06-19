# ADR 006: Jobs and console must set tenant context explicitly

**Status:** Accepted  
**Date:** 2026

## Context

uButeco uses shared-schema multi-tenant with request-scoped `Current.user` / `Current.organization` (`ActiveSupport::CurrentAttributes`). HTTP requests set `Current` via `SetCurrentTenant`. Sidekiq jobs and Rails console have **no automatic tenant**.

Agents often assume `Current.organization` is always available in background code.

## Decision

- **`Current` is request-scoped only** — set in `SetCurrentTenant` after auth; cleared after each request.
- **Sidekiq jobs** must either:
  - pass `organization_id` as an argument and set `Current.organization` at job start, or
  - scope all queries explicitly by `organization_id` without relying on `Current`.
- **Always** call `Current.reset` in job `ensure` when setting `Current` in a job.
- **Console / one-off scripts** — set `Current` manually or pass IDs explicitly; never assume tenant from a previous request.

Example: `ReindexJob` sets `Current.organization` for org-scoped reindex and resets in `ensure`.

## Consequences

- New jobs that touch tenant data must document required args in plan Manual steps.
- Code that reads `Current.organization` outside HTTP must verify context is set.
- AnyCable/Sidekiq kitchen broadcasts must pass org context in job args or channel subscription, not assume `Current` from enqueue time unless captured.

## References

- `app/models/current.rb`
- `app/controllers/concerns/set_current_tenant.rb`
- `app/sidekiq/reindex_job.rb`
- [architecture.md](../context/architecture.md)
