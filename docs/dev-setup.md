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

```bash
# 1. Infrastructure (from ubuteco_api)
docker compose up -d

# 2. API
cd ubuteco_api
cp .env-example .env   # if needed
bundle install
bin/rails db:create db:migrate
bin/rails s            # :3000

# 3. Background jobs (separate terminal)
bundle exec sidekiq

# 4. React (separate terminal)
cd ../ubuteco-react
npm install
npm run dev
```

## Environment

Copy `.env-example` → `.env`. Common variables:

- `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD` — PostgreSQL
- Redis / OpenSearch URLs (see `.env-example`)

React `.env` must point API and cable to your machine IP or localhost:

```
API_URL=http://localhost:3000/api
CABLE_URL=ws://localhost:8080/api/cable
```

## Database

- **Do not run migrations** when the user says the database is offline or they are working on another project.
- Fresh DB: `bin/rails db:drop db:create db:migrate` (Rails 8 may load `schema.rb` for versions already in the file — see plan notes if migrations conflict).
- Test DB: `RAILS_ENV=test bin/rails db:test:prepare`

## Tests

```bash
bundle exec rspec
bundle exec rspec spec/path/to_spec.rb
```

## Swagger

Generated from rswag specs. After API contract changes, regenerate when the plan requires it (see plan 08).
