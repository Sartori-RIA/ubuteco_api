# Plan template

Copy this file when adding a new plan. Name: `NN-short-slug.md` (same number in API and React when paired).

```markdown
# Plan: <Title>

**Status:** not started  
**Project:** ubuteco_api | ubuteco-react  
**Companion:** [link to other repo plan if any]  
**Branch:** `feature/<slug>`  
**Priority:** P0 | P1 | P2  
**Depends on:** [other plans]  
**Estimated effort:** N sprint(s)

---

## Goal

One paragraph: what problem this solves.

---

## Product decisions (lock before coding)

| Decision | Choice |
|----------|--------|
| … | … |

---

## Out of scope

- …

---

## Phase 1 — …

- [ ] Task
- [ ] Task

**Acceptance:** …

---

## Manual steps

- [ ] `bin/rails db:migrate` (when DB available)
- [ ] …

---

## Definition of done

- [ ] …

---

## References

- Code paths, ADRs, external docs
```

## Status legend

- Header `Status:` — `not started` · `in progress` · `done`
- Checkboxes — `[ ]` todo · `[~]` partial · `[x]` complete

## Rules

1. One plan → one git branch (`feature/<slug>`).
2. Update checkboxes as you work; keep companion plan in sync.
3. Put **manual** steps (migrations, deploy) in their own section — AI should not run them unless asked.
