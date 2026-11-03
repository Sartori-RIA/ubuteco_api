# Plan: AI daily brief

**Status:** completed  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — daily brief card](../../../ubuteco-react/docs/plans/18-ai-daily-brief.md)  
**Branch:** `feature/ai-daily-brief`  
**Priority:** P2  
**Depends on:** [16-ai-foundation](./16-ai-foundation.md), [04-organization-dashboard](./04-organization-dashboard.md), [09-inventory-stock](./09-inventory-stock.md); [15-product-expiry-alerts](./15-product-expiry-alerts.md) (recommended)  
**Estimated effort:** 0.5–1 sprint

---

## Goal

When the owner opens the dashboard, show a short paragraph: *"Yesterday you made $4,320 (+12 % vs. last week). The IPA sold out early; 3 units left. 2 items expire by Sunday."*

**The numbers come from code, the words come from the model.** A deterministic service builds a fact sheet; the model only turns it into 3–5 sentences. If the model fails, a plain template renders the same facts.

---

## Product decisions (lock before coding)

| Decision | Recommendation (v1) |
|----------|---------------------|
| Who | **ADMIN**, **CASH_REGISTER** (`:read, :dashboard`) |
| Period | "Yesterday" + "today so far", in **org timezone** |
| Trigger | **On demand** with cache (same pattern as `Organizations::Dashboard::Cache`), TTL 30 min. No scheduler in v1 (no cron gem in the stack). |
| Model tier | `:fast` |
| Fallback | Template text from the same facts when AI disabled or provider error — endpoint never 5xx's because of the model |
| Hallucination guard | Allow-list of pre-formatted numeric strings on the fact sheet. A number in the narrative that is not in that list → template. Never match raw cents (`"$4,320.00"` is not `432000`). |
| Language | Org locale |

---

## Out of scope (v1)

- Email / push delivery of the brief (v2 with a scheduler)
- Recommendations ("buy more X") — that is [19](./19-restock-suggestions.md)
- Per-user customisation

---

## Phase 1 — Fact sheet (no AI)

- [x] `Organizations::DailyBrief::Facts` → hash with:
  - revenue yesterday, same weekday last week, delta %
  - orders count, average ticket
  - top 3 products yesterday
  - low stock items (from `Inventory::LowStockQuery`)
  - expiring items (plan 15 query, if shipped)
  - kitchen: avg prep time (from `Organizations::Dashboard::Kitchen`)
- [x] Money as cents + currency; dates via `RangeParser` / org timezone
- [x] Spec with fixed time (`travel_to`) across timezones

**Acceptance:** facts correct for an org in `America/Sao_Paulo` and one in `America/Toronto` at 00:30 local.

---

## Phase 2 — Narrative

- [x] `Organizations::DailyBrief::Compose` → `Ai::Client.complete(feature: DAILY_BRIEF, tier: :fast)` with the fact sheet as JSON data block
- [x] Prompt in `app/prompts/daily_brief/system.md.erb`: max 5 sentences, org locale, money formatted by us (pass pre-formatted strings, e.g. `"$4,320.00"` for a USD org) so the model does not format currency
- [x] `Organizations::DailyBrief::NumberGuard` — extract numbers from output; reject if any is absent from the fact sheet
- [x] `Organizations::DailyBrief::Template` — i18n fallback (all locales in `config/locales`)

**Acceptance:** guard spec rejects an invented number; fallback used when AI disabled.

---

## Phase 3 — API

- [x] `GET /api/v1/dashboard/brief` → `{ text, source: "ai" | "template", facts: {...}, generated_at }`
- [x] Cached per org + date; `?refresh=1` busts cache (rate-limited)
- [x] rswag + drift check

**Acceptance:** request specs (ai / template / disabled), cross-tenant spec.

---

## Manual steps

- [x] None beyond plan 16 (no migration)

---

## Definition of done

- [x] Endpoint returns a brief for current org, AI or template
- [x] No number in AI text that is not in the facts
- [x] Swagger documented; React companion plan created

---

## References

- `app/services/organizations/dashboard/` (Summary, Kitchen, RangeParser, Cache)
- `app/services/inventory/low_stock_query.rb`
- [docs/context/dashboard.md](../context/dashboard.md)
