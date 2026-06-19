# Copilot instructions — ubuteco_api

Read **[AGENTS.md](./AGENTS.md)** before suggesting or editing code in this repository.

- Workflow (commits, PRs, quality gates): [docs/workflow-plans-and-git.md](docs/workflow-plans-and-git.md)
- Architecture & domain context: [docs/context/](docs/context/)
- Active work: pick one plan from [docs/plans/README.md](docs/plans/README.md)
- Small fixes: [docs/backlog/README.md](docs/backlog/README.md)

Stack: Ruby 4 / Rails 8.1 API-only, PostgreSQL, Sidekiq, Searchkick + OpenSearch, AnyCable, Devise JWT, CanCanCan.

Do not run `db:migrate` or destructive DB commands unless the user explicitly requests it.
