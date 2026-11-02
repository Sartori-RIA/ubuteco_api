# ADR 007: AI provider and gateway

**Status:** Accepted  
**Date:** 2026-11-02

## Context

Plans 17–21 each need a language model. Giving every feature its own HTTP client would scatter API keys, skip per-organization opt-in, and make it easy to leak one tenant's data into another tenant's prompt. Specs must not call the network.

## Decision

- **One gateway.** Features call `Ai::Client.complete`. They do not use the provider SDK.
- **Provider.** Anthropic, via the `anthropic` gem. `Ai::AnthropicClient` is the only class that knows the SDK. Embeddings are not part of this provider; `Ai::Embeddings` is reserved for plan 20.
- **Tiers, not model IDs.** Feature code passes `:fast` or `:smart`. `config/ai.yml` maps the tier to a model, with env overrides `AI_MODEL_FAST` and `AI_MODEL_SMART`.
- **Opt-in, default off.** `Ai.enabled_for?(organization)` is true only when `AI_ENABLED` is on and `organizations.ai_enabled` is true. An organization **ADMIN** toggles the flag. Subscription gating waits for plan 03.
- **No prompt storage.** `ai_usage_events` stores feature, model, tokens, latency, and status. Prompt and response text are logged only when `AI_LOG_CONTENT=1` and the environment is not production.
- **Tenant is an argument.** `organization:` is required. The gateway does not read `Current`, so jobs can call it. See [ADR 006](./006-jobs-and-current-tenant.md).
- **Limits.** Redis counters per organization, feature, and org-timezone minute/day. Defaults: 30/minute and 200/day (`AI_RATE_LIMIT_PER_MINUTE`, `AI_RATE_LIMIT_PER_DAY`).
- **Tests.** `Ai::FakeClient` is selected in the test environment. WebMock blocks other HTTP. A real key is not required.

## Consequences

- New AI features add an `Ai::Feature` constant and call the gateway.
- Provider errors become `ai_unavailable` (503). Opt-out is `ai_disabled` (403). The cap is `ai_rate_limited` (429). `ai_invalid_output` (502) is reserved for plan 21.
- Long or non-interactive work uses the Sidekiq `ai` queue and still passes `organization:` explicitly.
- `bin/rails db:migrate` adds `organizations.ai_enabled` and `ai_usage_events`.

## References

- [docs/context/ai.md](../context/ai.md)
- [Plan 16](../plans/16-ai-foundation.md)
