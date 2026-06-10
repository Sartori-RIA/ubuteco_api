# Workflow: plans, commits, and PRs

**Canonical source** for plan/git workflow in uButeco — use this file for any agent or human.

| Copy | Audience |
|------|----------|
| **This file** (`docs/workflow-plans-and-git.md`) | Source of truth — Copilot, Claude, CI, humans |
| [`.cursor/rules/plan-and-git-workflow.mdc`](../.cursor/rules/plan-and-git-workflow.mdc) | Cursor-only summary (`alwaysApply`); keep in sync with this doc |
| [AGENTS.md](../AGENTS.md) | Entry point — links here in *Before you code* |

When editing workflow rules, **change this file first**, then mirror to `.cursor/rules/`.

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

## 4. Quality gates **before** opening the PR

Run locally on the feature branch — **must pass** before `git push` / `gh pr create`. Matches [`.github/workflows/ci.yml`](../.github/workflows/ci.yml).

| Check | Command |
|-------|---------|
| **RuboCop** | `bin/rubocop` |
| **RSpec** (specs) | `bundle exec rspec` |
| **Code coverage** | Generated with RSpec (`coverage/` — SimpleCov); confirm no unexpected drops on changed areas |
| **Brakeman** | `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error` |
| **bundler-audit** | `bin/bundler-audit check --update` |
| **OpenAPI drift** (if API contract changed) | `bundle exec rake openapi:drift_check` |

**Shortcut:** `bin/ci` runs RuboCop, Brakeman, bundler-audit, RSpec, and OpenAPI drift (plus seeds). Requires local Postgres and env vars — see [dev-setup.md](./dev-setup.md).

Do not open a PR with failing specs, RuboCop offenses, Brakeman warnings, or bundler-audit vulnerabilities.

## 5. Open PR

- One plan per PR when possible; finish the plan in that PR.
- Body: summary bullets, link to plan file, test plan checklist.
- Cross-repo: link companion PR (e.g. API #42 ↔ React #26).

## 6. After merge

- README status should already be `completed` from step 3.
