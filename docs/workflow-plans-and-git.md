# Workflow: plans, commits, and PRs

Human + AI reference for uButeco. Cursor rule: [`.cursor/rules/plan-and-git-workflow.mdc`](../.cursor/rules/plan-and-git-workflow.mdc).

## Flow

```
Read plan → feature/<slug> branch → small commits → update plan → push → open PR
```

## 1. Start

- Pick **one** plan from [docs/plans/README.md](./plans/README.md).
- Branch: `feature/<plan-slug>` (e.g. `feature/inventory-stock`).

## 2. Commits (small)

Prefer **several small commits** over one large dump:

```text
docs(inventory): add context and plan tracking
feat(inventory): add stock adjustment API
feat(inventory): persist stock_movements audit trail
test(inventory): cover last-unit reservation
refactor(i18n): localize API error messages
docs(inventory): mark plan 09 completed
```

**Convention:** `type(scope): imperative summary` — types: `feat`, `fix`, `test`, `docs`, `refactor`.

## 3. Update plan **before** the PR

On the feature branch (same PR as code):

| File | What to update |
|------|----------------|
| `docs/plans/NN-*.md` | Header `Status:`, phase `[x]` / `[~]`, definition of done |
| `docs/plans/README.md` | Status column (`not started` · `in progress` · `completed`) |
| `docs/context/` | If API behavior or conventions changed |

Exception: plan/backlog **text-only** edits with no implementation can go straight to **`master`** (no PR), per [AGENTS.md](../AGENTS.md).

## 4. Open PR

- One plan per PR when possible; finish the plan in that PR.
- Body: summary bullets, link to plan file, test plan checklist.
- Cross-repo: link companion PR (e.g. API #42 ↔ React #26).

## 5. After merge

- README status should already be `completed` from step 3.
