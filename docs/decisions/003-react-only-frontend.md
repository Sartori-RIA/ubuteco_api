# ADR 003: React-only active frontend

**Status:** Accepted  
**Date:** 2026

## Context

uButeco had an Angular SPA (`ubuteco_spa`) and a newer Next.js app (`ubuteco-react`).

## Decision

- **All new features and fixes** go to `ubuteco-react` only.
- `ubuteco_spa` is **abandoned** — no migration, no feature parity effort.
- Org theme/color customizer (Angular-era) is removed; replaced by user-level dark mode.

## Consequences

- API plans may include a React companion doc under `ubuteco-react/docs/plans/`.
- Do not block API work on Angular updates.
- Documentation and AI context should not reference SPA patterns.

## References

- [ubuteco-react README.md](../../../ubuteco-react/README.md)
