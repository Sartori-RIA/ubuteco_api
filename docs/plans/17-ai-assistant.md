# Plan: AI assistant for owners (chat with tools)

**Status:** not started  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — assistant chat](../../../ubuteco-react/docs/plans/17-ai-assistant.md)  
**Branch:** `feature/ai-assistant`  
**Priority:** P3  
**Depends on:** [16-ai-foundation](./16-ai-foundation.md), [04-organization-dashboard](./04-organization-dashboard.md), [09-inventory-stock](./09-inventory-stock.md); [15-product-expiry-alerts](./15-product-expiry-alerts.md) (optional tool)  
**Estimated effort:** 2 sprints

---

## Goal

Let an ADMIN or CASH_REGISTER ask questions in plain language — *"what sold most on Friday?"*, *"what is running low?"*, *"how much did I make this week compared to last week?"* — and get an answer built from **real org data**.

The model never touches the database. It can only call a small set of **tools**, and each tool is an existing service wrapped with the caller's CanCanCan ability. The AI sees exactly what the user would see.

---

## Product decisions (lock before coding)

| Decision | Recommendation (v1) |
|----------|---------------------|
| Who | **ADMIN**, **CASH_REGISTER** (same as dashboard/inventory) |
| Read or write | **Read-only** in v1. No tool creates/edits orders, stock or products. |
| Data access | **Tool use over existing services** — no text-to-SQL. |
| Conversations persisted? | Yes — `ai_conversations` + `ai_messages`, org-scoped, owned by user; soft-delete. Retention 90 days. |
| Response delivery | v1: synchronous request with timeout (~25 s). v2: stream tokens over AnyCable (`AiAssistantChannel`). |
| Language | Answer in the **organization locale** (`organizations.locale`). |
| Money/dates | Tools return cents + currency and org-timezone dates; the model is told to not do its own math on raw values when a tool already returns totals. |
| Model tier | `:smart` (tool use) |

---

## Out of scope (v1)

- Write actions ("set the Heineken stock to 20") — see *Phase 6*
- Customer-facing assistant (CUSTOMER role)
- Voice input
- RAG over uploaded documents (no document corpus exists yet)

---

## Phase 1 — Tool registry

- [ ] `Ai::Assistant::Tool` base: `name`, `description`, JSON `input_schema`, `required_ability` (e.g. `[:read, :dashboard]`), `call(user:, organization:, args:)`
- [ ] Every tool runs `Ability.new(user).authorize!(*required_ability)` before executing
- [ ] v1 tools (wrap existing code, no new queries if avoidable):

| Tool | Wraps | Ability |
|------|-------|---------|
| `sales_summary(from, to)` | `Organizations::Dashboard::Summary` + `RangeParser` | `:read, :dashboard` |
| `sales_series(from, to, grain, metric)` | `Organizations::Dashboard::Series` | `:read, :dashboard` |
| `kitchen_metrics(from, to)` | `Organizations::Dashboard::Kitchen` | `:read, :dashboard` |
| `top_products(from, to, limit)` | new `Orders::TopProductsQuery` (order_items grouped by item) | `:read, :dashboard` |
| `low_stock()` | `Inventory::LowStockQuery` | `:read, :inventory` |
| `expiring_products()` | plan 15 query (only if shipped) | `:read, :inventory` |
| `search_catalog(query)` | `pagy_search_authorized` path for Beer/Wine/Drink/Food/Dish | `:read, <model>` |

- [ ] Tool outputs are compact JSON, capped in size (truncate lists to N rows)
- [ ] Unknown tool / invalid args → error returned to the model, not raised to the user

**Acceptance:** each tool has a spec including a user **without** the ability (raises/denied) and a cross-tenant case.

---

## Phase 2 — Agent loop

- [ ] `Ai::Assistant::Run` service: build system prompt (org name, locale, timezone, today's date, role) → `Ai::Client.complete(tier: :smart, tools:)` → execute tool calls → loop until final answer
- [ ] Hard caps: max **5** tool rounds, max tokens per turn, overall timeout
- [ ] Org data from tools goes in tool results only — never interpolated into the system prompt as instructions
- [ ] System prompt in `app/prompts/assistant/system.md.erb` (versioned in git)
- [ ] If a question needs data no tool provides → answer says so (no guessing). Covered by an eval case.

**Acceptance:** spec with `Ai::FakeClient` scripting a 2-tool conversation end to end.

---

## Phase 3 — Persistence & API

- [ ] Migrations: `ai_conversations` (`organization_id`, `user_id`, `title`, `deleted_at`), `ai_messages` (`ai_conversation_id`, `role`, `content` jsonb, `tool_name`, `usage` jsonb)
- [ ] Endpoints:
  - `POST /api/v1/assistant/conversations` → create
  - `GET /api/v1/assistant/conversations` → list own
  - `GET /api/v1/assistant/conversations/:id` → messages
  - `POST /api/v1/assistant/conversations/:id/messages` → `{ content }` → assistant reply
  - `DELETE /api/v1/assistant/conversations/:id`
- [ ] Ability `:use, :assistant` (ADMIN, CASH_REGISTER) + `Ai.enabled_for?` gate → `ai_disabled`
- [ ] rswag + drift check

**Acceptance:** request specs; user A cannot read user B's conversation even in same org; cross-tenant spec.

---

## Phase 4 — Quality (evals)

- [ ] `spec/ai_evals/assistant/*.yml` — question + fixture org data + expected tool(s) + facts that must appear
- [ ] `bin/rails ai:eval[assistant]` runs them against the **real** model (manual, not CI) and prints a pass/fail table
- [ ] Minimum set: top seller, revenue comparison, low stock, "unknown data" refusal, Portuguese and English org

**Acceptance:** ≥ 90 % eval pass before enabling for any real org.

---

## Phase 5 — Streaming (v2)

- [ ] `AiAssistantChannel` on AnyCable, stream keyed by conversation id + user
- [ ] Message endpoint returns `202` and streams deltas + tool status ("checking sales…")

---

## Phase 6 — Write actions (future, separate plan)

- [ ] Proposal-only pattern: model returns a *proposed* action; UI shows confirm button; the **existing** endpoint executes it. The model never mutates directly.

---

## Manual steps

- [ ] `bin/rails db:migrate` (ai_conversations, ai_messages)
- [ ] Enable `ai_enabled` for a test org on staging
- [ ] Run `bin/rails ai:eval[assistant]` with a real key before rollout

---

## Definition of done

- [ ] ADMIN/CASH_REGISTER can ask questions and get answers grounded in tool results
- [ ] Every tool authorization-checked; cross-tenant specs pass
- [ ] Evals ≥ 90 %; usage visible in `ai_usage_events`
- [ ] Swagger documented; React companion plan created

---

## References

- `app/services/organizations/dashboard/`
- `app/services/inventory/low_stock_query.rb`
- `app/controllers/concerns/searchkick_authorizable.rb`
- `app/models/abilities/`
- [docs/context/dashboard.md](../context/dashboard.md), [inventory-stock.md](../context/inventory-stock.md)
