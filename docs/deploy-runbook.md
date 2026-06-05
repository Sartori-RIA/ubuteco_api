# Deploy runbook (API)

Staging/production checklist for **ubuteco_api**. Topology should match [docker-compose.yml](../docker-compose.yml): API, Sidekiq, Postgres, Redis, OpenSearch, AnyCable-go.

## Pre-deploy

- [ ] Env vars set (see [.env-example](../.env-example)): `SECRET_KEY_BASE`, `JWT_SECRET`, `DATABASE_URL`, `REDIS_URL`, `OPENSEARCH_URL`, `CORS_ORIGINS`, `ANYCABLE_*`
- [ ] `ANYCABLE_ALLOWED_ORIGINS` — explicit frontend URLs (no `*` in prod)
- [ ] Rotate `ANYCABLE_SECRET` and `JWT_SECRET` per environment

## Deploy steps

1. Build and push the Docker image (same `Dockerfile` as dev).
2. Run migrations: `bin/rails db:migrate`
3. Restart **Puma** and **Sidekiq** workers.
4. After schema/index changes: `bin/rails searchkick:reindex` (or org-scoped tasks when available — see plan 07).
5. Smoke test:
   - `GET /up` → `{ "status": "ok", "redis": "ok" }`
   - Sign in, list orders, kitchen WebSocket receives a broadcast

## Rollback

1. Redeploy previous image tag.
2. If migration was destructive, restore DB backup before rollback.
3. Reindex OpenSearch if index mapping changed.

## References

- [README — CI required checks](../README.md#ci-required-checks)
- [dev-setup.md](dev-setup.md)
- Plan 05 §6 production infrastructure
