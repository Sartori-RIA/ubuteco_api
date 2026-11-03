# ADR 008: Catalog embeddings

**Status:** Accepted  
**Date:** 2026-11-02

## Context

Plan 20 adds semantic catalog search on the OpenSearch cluster we already run (2.11.1). Searchkick 6.0.3 can issue a k-NN query when the index mapping declares `knn`. Anthropic has no embeddings API ([ADR 007](./007-ai-provider-and-gateway.md)).

A live Portuguese quality comparison needs a provider key and a seeded catalog. This environment has neither Voyage nor OpenAI credentials, so the quality column is intentionally blank.

## Decision

- **Provider.** Voyage AI, model `voyage-3-lite` (512 dimensions, cosine). It is Anthropic's embeddings partner, so it stays beside the existing gateway instead of adding a self-hosted model on the cluster. Override the model with `EMBEDDING_MODEL`. The key is `VOYAGE_API_KEY`.
- **No key, no vectors.** `Ai::Embeddings` raises `Ai::ProviderError` when the key is missing. Catalog search then keeps the keyword results. A missing or failing embedder is not a 503. OpenSearch itself being down still is.
- **Tests.** `Ai::Embeddings::Fake` returns a deterministic 512-dimension vector. It does not call the network.
- **What is embedded.** Beer, Wine, Drink, Food, and Dish. The text is name, description, flavor, grapes, style, maker, and dish ingredient names. `embedding_digest` stores the SHA256 of that text so an unchanged product is not embedded again. The vector is stored as `jsonb` and copied into `search_data` so a later keyword reindex does not drop it.
- **When.** `EmbedProductJob` on the `ai` queue, after create or update, only when the digest changed. The job sets `Current.organization` and resets it in `ensure`.
- **Query.** `?mode=keyword` stays keyword. `?mode=semantic` and `?mode=hybrid` embed the query, run k-NN with the same organization filter as keyword search, and hybrid merges the two lists with reciprocal rank fusion. With no `mode`, opted-in organizations (`Ai.enabled_for?`) use hybrid and everyone else stays on keyword.

## Consequences

- Adding the k-NN mapping requires a catalog reindex after deploy.
- Backfill is `bin/rails catalog:embed:organization[ORG_ID]`. It stops spending when the org rate limit is hit; run it again later for rows whose digest is still empty.
- The Portuguese bake-off (about 50 products, 15 queries) is still a manual step once `VOYAGE_API_KEY` exists. Do not treat the fake vectors as a quality score.

## References

- [20-semantic-menu-search](../plans/20-semantic-menu-search.md)
- [search-and-opensearch.md](../context/search-and-opensearch.md)
