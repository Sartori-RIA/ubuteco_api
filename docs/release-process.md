# Release process (API + React)

Coordinated release for **ubuteco_api** and **ubuteco-react**. Infrastructure details: [deploy-runbook.md](./deploy-runbook.md).

## When to release

- After `master` / `main` CI is green on both repos
- OpenAPI drift check passes on API (`rake openapi:drift_check`)
- No pending destructive migration without backup plan

## Version tag

1. Choose semver tag on API repo, e.g. `v2026.06.1` (API is source of truth for backend deploy).
2. Optionally tag React with same label for traceability.

```bash
git tag -a v2026.06.1 -m "Release v2026.06.1"
git push origin v2026.06.1
```

## Deploy sequence

| Step | Repo | Action |
|------|------|--------|
| 1 | API | Build/push Docker image; deploy **api** service (migrations run via entrypoint `db:prepare`) |
| 2 | API | Redeploy **sidekiq** with same image tag |
| 3 | API | If search mappings changed: `bin/rails searchkick:reindex:model[ModelName]` — see [search-operations-runbook.md](./search-operations-runbook.md) |
| 4 | React | Deploy front with `NEXT_PUBLIC_API_URL` and `CABLE_URL` pointing at production |
| 5 | Both | Smoke test (below) |

## Smoke test checklist

- [ ] `GET /up` → `{ "status": "ok", "redis": "ok" }`
- [ ] Sign in as org admin
- [ ] List orders; open kitchen queue
- [ ] Kitchen WebSocket receives item status broadcast (AnyCable)
- [ ] Create order line item; confirm stock decrement if product is stockable
- [ ] Sign out

## OpenAPI docs (GitHub Pages)

On **GitHub Release published**, workflow `.github/workflows/pages.yml` deploys `docs/` (static Swagger UI + synced `swagger.yaml`).

Manual sync before release:

```bash
bundle exec rake openapi:refresh
git add swagger/v1/swagger.yaml docs/swagger.yaml
```

## Rollback

See [deploy-runbook.md — Rollback](./deploy-runbook.md#rollback). Roll back API image first; then React if the front change caused the issue.

## References

- [deploy-runbook.md](./deploy-runbook.md)
- [dev-setup.md](./dev-setup.md)
- Plan 08 — API contract & CI/CD
