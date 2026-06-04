# Development setup — ubuteco_api

## Prerequisites

- Ruby (see `.ruby-version`), Bundler
- Docker Compose for infrastructure (PostgreSQL, Redis, OpenSearch, AnyCable, Mailcatcher)
- Sibling checkout: [ubuteco-react](../ubuteco-react)

Full architecture diagram: [README.md](../README.md#system-architecture).

## Default ports

| Service | Port | URL |
|---------|------|-----|
| Rails API (Puma) | 3000 | `http://localhost:3000` |
| PostgreSQL | 5432 | — |
| Redis | 6379 | — |
| OpenSearch | 9200 | `http://localhost:9200` |
| anycable-go (WebSocket) | 8080 | `ws://localhost:8080/api/cable` |
| Next.js (sibling repo) | 3001* | `http://localhost:3001` |

\*React may use another port if 3001 is busy (`PORT=4000 npm run dev`). Check terminal output.

## Typical flow

### Docker (recommended — API + Sidekiq in containers)

```bash
cd ubuteco_api
cp .env-example .env   # optional when using compose defaults
docker compose up -d --build
docker compose logs -f api   # first boot runs db:prepare
```

Containers: `ubuteco_api` (:3000), `ubuteco_sidekiq`, `ubuteco_db`, `ubuteco_redis`, OpenSearch, Mailcatcher, AnyCable.

```bash
# React (separate terminal)
cd ../ubuteco-react
npm install
npm run dev
```

### Host Rails (infra only in Docker)

If you prefer `bin/rails s` on the host, start infra without the API containers:

```bash
docker compose up -d db cache mailcatcher opensearch-node1 opensearch-node2 opensearch-dashboards anycable-ws
```

For AnyCable with host Rails, set `ANYCABLE_RPC_HOST=host.docker.internal:50051` on `anycable-ws` (see README).

Then on the host:

```bash
bundle install
bin/rails db:create db:migrate
bin/rails s
bundle exec sidekiq   # separate terminal
```

## Environment

Copy `.env-example` → `.env`. Common variables:

- `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD` — PostgreSQL
- `JWT_SECRET` — required; tokens expire after **24 hours** (see [api-conventions.md](plans/api-conventions.md))
- `CORS_ORIGINS` — required in staging/production (comma-separated frontend URLs)
- Redis / OpenSearch URLs (see `.env-example`)

Health check: `GET /up` (no auth) — returns `{ status, redis }`.

React `.env` must point API and cable to your machine IP or localhost:

```
API_URL=http://localhost:3000/api
CABLE_URL=ws://localhost:8080/api/cable
```

## Database

Order matters: **migrate → seed → populate** (`populate` needs roles and styles from seed).

**Docker (recommended):**

```bash
docker compose exec api bin/rails db:migrate
docker compose exec api bin/rails db:seed      # roles, beer/wine styles
docker compose exec api bin/rails db:populate  # fake catalog + dev users
```

Fresh database:

```bash
docker compose exec api bin/rails db:drop db:create db:migrate db:seed db:populate
```

**Host Rails:** use `bin/rails` instead of `docker compose exec api bin/rails`.

- **Do not run migrations** when the database is offline or you are working on another project.
- Test DB: `RAILS_ENV=test bin/rails db:test:prepare` (or via `docker compose exec api`)

## Tests

```bash
bundle exec rspec
bundle exec rspec spec/path/to_spec.rb
```

**Docker** — install test gems and run with `RAILS_ENV=test`:

```bash
docker compose exec -e RAILS_ENV=test api bundle install
docker compose exec -e RAILS_ENV=test api bundle exec rspec
```

## Swagger

Generated from rswag specs. After API contract changes, regenerate when the plan requires it (see plan 08).
