# ADR 001: Shared-schema multi-tenant

**Status:** Accepted  
**Date:** 2026 (documented from plan 01)

## Context

uButeco serves many restaurant organizations. We need tenant isolation, super-admin platform access, and compatibility with Searchkick, Sidekiq, and AnyCable.

## Decision

Use **one PostgreSQL schema** with `organization_id` on tenant-owned tables, plus request-scoped `Current.organization` / `Current.user`.

Do **not** use schema-per-tenant (e.g. Apartment) in the initial architecture.

## Consequences

- Migrations and CI stay standard Rails.
- Abilities and explicit query scoping are required — no reliance on `default_scope` alone.
- Cross-tenant IDOR must be prevented in controllers (do not trust param `organization_id` on create).
- Stronger DB isolation (RLS) can be added later without changing the tenant column model.

## References

- [docs/plans/01-multi-tenant.md](../plans/01-multi-tenant.md)
- `app/models/current.rb`
