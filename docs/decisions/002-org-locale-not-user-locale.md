# ADR 002: Organization-level locale (v1)

**Status:** Accepted  
**Date:** 2026 (documented from plan 02)

## Context

Restaurants need consistent money and date formatting. Users asked whether locale/currency/timezone should be per-user or per-organization.

## Decision

**Organization** is the source of truth for `locale`, `default_currency`, and `timezone` in v1.

- UI strings may stay single-language until a later i18n pass (`next-intl` optional in plan 02 phase 4).
- API error messages use Rails I18n; per-request locale switching is a separate phase.

## Consequences

- All staff in an org see the same formatting.
- Changing currency affects **new** products/orders only; historical orders keep snapshotted currency columns.
- Settings UI is **admin-only**.

## References

- [docs/plans/02-locale-and-currency.md](../plans/02-locale-and-currency.md)
