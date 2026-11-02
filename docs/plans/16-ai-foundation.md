# Plan: AI foundation (LLM gateway, usage, guardrails)

**Status:** not started  
**Project:** ubuteco_api  
**Companion:** [ubuteco-react — AI settings toggle](../../../ubuteco-react/docs/plans/16-ai-settings.md)  
**Branch:** `feature/ai-foundation`  
**Priority:** P2  
**Depends on:** [01-multi-tenant](./01-multi-tenant.md), [05-platform-hardening](./05-platform-hardening.md) (rate limiting already in place)  
**Estimated effort:** 1 sprint

---

## Goal

Give every AI feature (plans 17–21) **one shared, boring layer** to call a language model: a single client, per-org opt-in, usage and cost accounting, rate limits, and a test double so CI never hits the network. Without this, each feature would grow its own HTTP client, API key handling and tenant leaks.

This plan ships **no user-facing AI**. It is the plumbing.

---

## Product decisions (lock before coding)

| Decision | Recommendation (v1) |
|----------|---------------------|
| Provider | **Anthropic (Claude)** via the official Ruby SDK (`anthropic` gem). Keep a provider-agnostic interface so another one can be added later. |
| Model choice | **Tiers, not model IDs in feature code**: `:fast` (cheap, short tasks) and `:smart` (reasoning/tool use). Map tier → model ID in one config file, overridable by env. |
| Embeddings provider | Anthropic has no embeddings API. Decide in [20](./20-semantic-menu-search.md); this plan only reserves an `Ai::Embeddings` interface. |
| Opt-in | **Per organization**, default **off**. `organizations.ai_enabled` boolean. Global kill switch via `AI_ENABLED` env. |
| Who can use AI | Roles decided per feature; foundation only exposes `Ai.enabled_for?(organization)`. |
| Store prompts/responses? | **No** by default — store metadata only (tokens, latency, feature, status). Content logging only behind `AI_LOG_CONTENT=1` in non-production. |
| Rate limit | Per org, per feature: e.g. 200 calls/day + 30/min (env-configurable). |
| Background vs inline | Anything > ~5 s or non-interactive runs in **Sidekiq** (new `ai` queue). |
| Subscription gating | Later — when [03](./03-subscription-plans.md) lands, add `feature?(:ai)` check inside `Ai.enabled_for?`. |

---

## Out of scope

- Any feature that calls the model (plans 17–21)
- Fine-tuning or self-hosted models
- Prompt management UI
- Billing customers for AI usage

---

## Phase 1 — Decision record & context doc

- [ ] ADR `docs/decisions/007-ai-provider-and-gateway.md` — provider, tiers, no-content-logging default, opt-in per org
- [ ] `docs/context/ai.md` — how to call `Ai::Client`, tiers, tenant rules, testing, pitfalls
- [ ] Add AI rows to `docs/context/common-ai-pitfalls.md` (see *Pitfalls to document* below)
- [ ] Link `ai.md` from `AGENTS.md` *Key paths*

**Acceptance:** ADR accepted; context doc reviewed.

---

## Phase 2 — Client

- [ ] Add `anthropic` gem; `ANTHROPIC_API_KEY` in `.env-example` (never committed)
- [ ] `config/ai.yml` (or initializer): tier → model ID, max tokens, timeouts; env overrides `AI_MODEL_FAST`, `AI_MODEL_SMART`
- [ ] `Ai::Client` — single entry point:
  - `Ai::Client.complete(feature:, tier:, system:, messages:, tools: nil, organization:, user: nil)`
  - Requires `organization:` explicitly (do **not** read `Current` inside — works in jobs per [ADR 006](../decisions/006-jobs-and-current-tenant.md))
  - Raises `Ai::DisabledError` when org/global disabled
  - Raises `Ai::RateLimitedError`, `Ai::ProviderError` (wraps timeouts/5xx)
  - Returns a small value object (`text`, `tool_calls`, `usage`, `stop_reason`)
- [ ] `Ai::Feature` constants — `ASSISTANT`, `DAILY_BRIEF`, `RESTOCK_EXPLAIN`, `MENU_SEARCH`, `PRODUCT_INTAKE` (no magic strings)
- [ ] Map errors to structured API errors via `ApiErrorRenderable`: `ai_disabled` (403), `ai_rate_limited` (429), `ai_unavailable` (503), `ai_invalid_output` (502). The last one is for a feature that asked for structured output and got a response that failed schema validation ([21](./21-ai-product-intake.md) raises it; the foundation only reserves the code).

**Acceptance:** unit specs for disabled/ratelimited/provider-error paths using the fake client.

---

## Phase 3 — Org opt-in

- [ ] Migration: `organizations.ai_enabled boolean default false null false`
- [ ] Permit `ai_enabled` in org update for **ADMIN** only
- [ ] Expose in organization JSON + rswag
- [ ] `Ai.enabled_for?(organization)` = `AI_ENABLED` env && `organization.ai_enabled`

**Acceptance:** request spec — ADMIN toggles, WAITER cannot; cross-tenant spec.

---

## Phase 4 — Usage accounting & limits

- [ ] Table `ai_usage_events`: `organization_id` (not null), `user_id`, `feature`, `model`, `input_tokens`, `output_tokens`, `latency_ms`, `status` (enum: ok, error, rate_limited, disabled), timestamps; index `(organization_id, created_at)`
- [ ] Written by `Ai::Client` on every call (success or failure)
- [ ] `Ai::RateLimiter` — Redis counters per `org:feature:minute` and `org:feature:day`
- [ ] Platform read endpoint `GET /api/v1/platform/ai_usage` (SUPER_ADMIN) — totals per org/feature/day for cost watching

**Acceptance:** limiter spec (boundary at N and N+1); usage row written on error too.

---

## Phase 5 — Testing support

- [ ] `Ai::FakeClient` selected in test env — deterministic canned responses, can script tool calls
- [ ] Add `webmock` to test group; block real HTTP in specs
- [ ] Shared example `it_behaves_like 'an AI feature gated by org opt-in'`
- [ ] `spec/support/ai.rb` documented in `docs/context/testing.md`

**Acceptance:** `bundle exec rspec` passes with no `ANTHROPIC_API_KEY` set.

---

## Pitfalls to document

| Pitfall | Correct approach |
|---------|------------------|
| Call the provider SDK directly from a feature | Always `Ai::Client` (usage, limits, opt-in) |
| Hardcode a model ID in a service | Use a tier (`:fast` / `:smart`) |
| Read `Current.organization` inside AI code | Pass `organization:` explicitly |
| Trust model output as data | Validate/parse into a schema; model output is untrusted input |
| Put product names/notes in the *system* prompt as instructions | User-generated text goes in clearly delimited data blocks (prompt injection) |
| Hit the real API in specs | `Ai::FakeClient`; webmock blocks network |

---

## Manual steps

- [ ] `bin/rails db:migrate` (organizations.ai_enabled, ai_usage_events) when DB available
- [ ] Create Anthropic API key; set `ANTHROPIC_API_KEY`, `AI_ENABLED=1` on Railway (staging first)
- [ ] Add `ai` queue to `config/sidekiq.yml`

---

## Definition of done

- [ ] `Ai::Client` callable with tiers, opt-in, limits, usage rows
- [ ] Org `ai_enabled` toggle via API, ADMIN only
- [ ] Specs green without network; rswag + `openapi:drift_check` pass
- [ ] ADR 007 + `docs/context/ai.md` published

---

## References

- [ADR 006 — jobs and Current](../decisions/006-jobs-and-current-tenant.md)
- `config/initializers/rack_attack.rb` (existing throttling)
- `app/controllers/concerns/api_error_renderable.rb`
- Anthropic Ruby SDK: https://github.com/anthropics/anthropic-sdk-ruby
