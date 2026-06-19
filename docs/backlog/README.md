# Backlog — bugs & quick improvements (API)

Lightweight triage for **small, scoped** API fixes — without the full multi-phase structure of [plans](../plans/README.md).

## When to use what

| Situation | Where |
|-----------|--------|
| Multi-phase feature, new domain, API + React pairing | [docs/plans/](../plans/README.md) |
| Single bug, small API fix, one-endpoint polish | **This backlog** |
| Architectural decision with long-term impact | [docs/decisions/](../decisions/) |
| Frequent agent mistakes | [context/common-ai-pitfalls.md](../context/common-ai-pitfalls.md) |

If a backlog item grows beyond ~0.5 sprint or needs phased rollout, **promote it to a plan** (copy [TEMPLATE](../plans/TEMPLATE.md), add to plans README, open `feature/<slug>` branch).

## Entry format

One file per item: `NNN-short-slug.md` (zero-padded number, kebab slug).

```markdown
# <Title>

**Status:** open | in progress | done | wontfix  
**Priority:** P0 | P1 | P2 | P3  
**Area:** e.g. orders, search, auth  
**Plan:** link if promoted, or —  
**Branch:** `fix/<slug>` or `feature/<plan-slug>`

## Problem

What breaks / wrong behaviour.

## Expected

Correct behaviour.

## Notes

Controllers, specs, related issues.
```

## Status legend

`open` · `in progress` · `done` · `wontfix`

## Index

| # | Item | Priority | Status |
|---|------|----------|--------|
| — | *(empty — add entries as needed)* | — | — |

## Workflow

- Backlog-only edits → commit on **`master`** (no PR), same as plan doc text updates per [AGENTS.md](../../AGENTS.md).
- Code fix → `fix/<slug>` branch, small commits, quality gates before PR.
