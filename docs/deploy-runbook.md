# Deploy runbook (API)

Staging/production checklist for **ubuteco_api**. Local topology matches [docker-compose.yml](../docker-compose.yml). **Railway** topology is documented below.

## Pre-deploy

- [ ] Env vars set (see [.env-example](../.env-example)): `SECRET_KEY_BASE`, `JWT_SECRET`, `REDIS_URL`, `OPENSEARCH_URL`, `CORS_ORIGINS`, `ANYCABLE_*`
- [ ] `DATABASE_URL` (Railway Postgres) or `DB_*` for non-Railway hosts
- [ ] Active Storage: `AWS_BUCKET`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_ENDPOINT_URL` (T3/S3)
- [ ] Mailer: `MAILER_ADDRESS`, `MAILER_PASSWORD`, `MAILER_HOST` (Resend SMTP in prod)
- [ ] `ANYCABLE_ALLOWED_ORIGINS` — explicit frontend URLs (no `*` in prod)
- [ ] Rotate `ANYCABLE_SECRET` and `JWT_SECRET` per environment

## Railway services

| Service | Image / build | Start command | Notes |
|---------|---------------|---------------|-------|
| **postgres** | Railway plugin | — | Injects `DATABASE_URL` into linked services |
| **redis** | Railway plugin | — | Use private `REDIS_URL` on api, sidekiq, anycable-go |
| **api** | Repo `Dockerfile` | default (`bin/rails server`) | Puma on `$PORT`; AnyCable gRPC embedded on `:50051` |
| **sidekiq** | Same image as api | `bundle exec sidekiq -C config/sidekiq.yml` | Set `SKIP_DB_PREPARE=1`; same env as api |
| **anycable-go** | `anycable/anycable-go:1.6` | default | `ANYCABLE_RPC_HOST=api.railway.internal:50051`, `ANYCABLE_REDIS_URL=${{Redis.REDIS_URL}}`, `ANYCABLE_SECRET`, `ANYCABLE_ALLOWED_ORIGINS` |
| **opensearch** | Platform template | — | `OPENSEARCH_URL`, optional `SEARCHKICK_INDEX_PREFIX` |
| **react** | Separate repo | — | `API_URL`, `CABLE_URL` pointing at api / anycable-go public URLs |

### API env (shared with Sidekiq unless noted)

```
RAILS_ENV=production
SECRET_KEY_BASE=...
JWT_SECRET=...
DATABASE_URL=...          # from Postgres plugin
REDIS_URL=...             # private URL from Redis plugin
OPENSEARCH_URL=...
SEARCHKICK_INDEX_PREFIX=production
CORS_ORIGINS=https://app.example.com
ANYCABLE_SECRET=...
ANYCABLE_HTTP_BROADCAST_URL=https://<anycable-go-public>/_broadcast
ANYCABLE_WEBSOCKET_URL=wss://<anycable-go-public>/api/cable
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=auto
AWS_BUCKET=...
AWS_ENDPOINT_URL=https://t3.storageapi.dev
MAILER_ADDRESS=smtp.resend.com
MAILER_PORT=587
MAILER_SMTP_USER=resend
MAILER_PASSWORD=re_...
MAILER_HOST=app.example.com
```

Sidekiq-only: `SKIP_DB_PREPARE=1`.

Health check: `GET /up` → `{ "status": "ok", "redis": "ok" }` ([railway.toml](../railway.toml)).

## Deploy steps

1. Build and push the Docker image (same `Dockerfile`; `RAILS_ENV=production` by default).
2. API entrypoint runs `db:prepare` on boot (migrations + schema load if empty DB).
3. Restart **Sidekiq** after API deploy (or redeploy sidekiq service with same tag).
4. After schema/index changes: `bin/rails searchkick:reindex:model[ModelName]` or `searchkick:reindex:organization[ORG_ID]` — see [search-operations-runbook.md](search-operations-runbook.md).
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
- [search-operations-runbook.md](search-operations-runbook.md)
- Plan 05 §6 production infrastructure
