# Plan: Semantic menu search (embeddings + OpenSearch k-NN)

**Status:** not started  
**Project:** ubuteco_api (primary)  
**Companion:** _(none — existing search boxes get hybrid results transparently; add a React plan only if a mode toggle or new copy is wanted)_  
**Branch:** `feature/semantic-menu-search`  
**Priority:** P3  
**Depends on:** [07-search-operations](./07-search-operations.md), [16-ai-foundation](./16-ai-foundation.md)  
**Estimated effort:** 1–1.5 sprints

---

## Goal

Make catalog search understand **meaning**, not only words: *"something light and citrusy"* finds a witbier and a caipirinha; *"something to go with beer"* finds bar snacks. Today Searchkick only matches text.

We already run OpenSearch, which supports vector (k-NN) search, so no new database is needed. Each product gets an **embedding** (a list of numbers that represents its meaning); a query is embedded the same way and the closest products come back. Combined with the existing keyword search = **hybrid search**.

This is the same building block as RAG (retrieve relevant items before answering); the assistant ([17](./17-ai-assistant.md)) can reuse it as its `search_catalog` tool.

---

## Product decisions (lock before coding)

| Decision | Recommendation (v1) |
|----------|---------------------|
| Embeddings provider | **Decide in Phase 1 spike.** Options: Voyage AI (Anthropic's recommended partner), OpenAI `text-embedding-3-small`, or OpenSearch ML Commons neural plugin (self-hosted model). Pick on PT-BR quality + cost. |
| Models indexed | Beer, Wine, Drink, Food, Dish |
| Text embedded | Only columns that exist. **Beer:** name, description, style, maker, abv, ibu. **Wine:** name, description, maker, style, grapes, visual, ripening (no flavor column). **Drink:** name, description, flavor. **Food:** name only. **Dish:** name + ingredient names (no `description`). |
| When computed | Async in Sidekiq after create/update (only when embedded fields change) — never in the request |
| Search mode | **Hybrid**: keyword + vector, merged; keyword-only fallback when AI disabled or embeddings missing |
| Tenant isolation | Org filter applied **inside** the k-NN query (same `SearchkickAuthorizable` rules) |
| Who | Anyone who can read the catalog today |

---

## Out of scope (v1)

- Semantic search over orders/users
- Image embeddings
- Personalised recommendations

---

## Phase 1 — Spike (time-boxed, 2 days)

- [ ] Confirm Searchkick 6.0.3 `knn` support with our OpenSearch version (local docker image); otherwise plan a raw OpenSearch query path
- [ ] Embed ~50 seeded products with 2 providers; run 15 PT-BR queries; record hit quality in this plan
- [ ] Decide provider + vector dimensions; record in ADR 007 (from plan 16) or new ADR 008

**Acceptance:** decision table filled in below.

| Provider | Dims | PT-BR quality (x/15) | Cost / 1k products | Chosen |
|----------|------|----------------------|--------------------|--------|
| … | … | … | … | … |

---

## Phase 2 — Embedding pipeline

- [ ] `Ai::Embeddings.embed(texts, organization:)` (interface from plan 16) + usage rows
- [ ] `Catalog::EmbeddingText.for(record)` — deterministic text builder per model
- [ ] Column or index-only storage: store `embedding_digest` (hash of embedded text) on records to skip unchanged updates
- [ ] `EmbedProductJob(model_name, record_id, organization_id)` on `ai` queue; sets/resets `Current` per [ADR 006](../decisions/006-jobs-and-current-tenant.md)
- [ ] Add vector to `search_data` + k-NN mapping
- [ ] Rake: `catalog:embed:organization[ORG_ID]` for backfill (batched, rate-limited)

**Acceptance:** job spec; unchanged text does not re-embed; cross-tenant: job for org A never writes org B docs.

---

## Phase 3 — Hybrid query

- [ ] `Catalog::SemanticSearch` — embed query (cache by normalized text, 1 h), k-NN with org filter, merge with keyword results (reciprocal rank fusion)
- [ ] `?mode=semantic|keyword|hybrid` on catalog index endpoints (default `keyword` until rollout, then `hybrid` for opted-in orgs)
- [ ] OpenSearch down → existing `search_unavailable` 503; embeddings provider down → keyword fallback (not an error)
- [ ] rswag + drift check

**Acceptance:** request specs per mode; `spec/security/cross_tenant/search_spec.rb` extended for semantic mode.

---

## Manual steps

- [ ] Possible migration for `embedding_digest` columns
- [ ] Reindex catalog after mapping change: `bin/rails searchkick:reindex:model[Beer]` etc.
- [ ] Backfill embeddings per org with the rake task
- [ ] Set embeddings provider key on Railway

---

## Definition of done

- [ ] Opted-in orgs get hybrid search; others unchanged
- [ ] Tenant filter enforced in vector queries (spec)
- [ ] Context doc `search-and-opensearch.md` updated with embeddings section

---

## References

- `app/controllers/concerns/searchkick_authorizable.rb`
- `app/sidekiq/reindex_job.rb`
- [docs/context/search-and-opensearch.md](../context/search-and-opensearch.md)
- [search-operations-runbook.md](../search-operations-runbook.md)
