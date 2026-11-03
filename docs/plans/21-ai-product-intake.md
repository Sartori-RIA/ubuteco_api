# Plan: AI product intake (photo / invoice → product draft)

**Status:** completed  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — label photo & invoice intake](../../../ubuteco-react/docs/plans/21-ai-product-intake.md)  
**Branch:** `feature/ai-product-intake`  
**Priority:** P3  
**Depends on:** [16-ai-foundation](./16-ai-foundation.md), [09-inventory-stock](./09-inventory-stock.md)  
**Estimated effort:** 1.5–2 sprints

---

## Goal

Cut the typing when registering products or receiving a delivery:

1. **Label photo → product draft**: photograph a beer/wine label, get name, maker, style, ABV, description pre-filled.
2. **Supplier invoice (NF-e) → stock draft**: upload the invoice, get a list of matched products + quantities to add to stock.

The AI **only drafts**. Nothing is saved until the user reviews and confirms through the **existing** create/stock endpoints.

---

## Product decisions (lock before coding)

| Decision | Recommendation (v1) |
|----------|---------------------|
| Who | **ADMIN**, **CASH_REGISTER** |
| Persistence | Endpoints return a draft JSON only; confirmation uses existing `POST /beers` etc. and `PATCH .../stock` |
| NF-e XML | **Parse deterministically** (it is structured XML) — no AI needed. AI only for photos / DANFE PDFs / handwritten notes. |
| Product matching (invoice line → catalog item) | Keyword search first; semantic search ([20](./20-semantic-menu-search.md)) when available; low-confidence lines left unmatched for the user |
| Model tier | `:smart` with image input |
| Upload limits | JPEG/PNG/PDF, ≤ 5 MB, 1 file per request |
| Image retention | Do not store the upload unless user confirms and chooses it as product image (Active Storage `image` on Product) |
| Price | Never trust price from a label photo; invoice unit cost shown but product sale price stays manual |

---

## Out of scope (v1)

- Automatic product creation without review
- Fetching NF-e from SEFAZ by access key
- Supplier management / purchase cost history

---

## Phase 1 — NF-e XML import (no AI)

- [ ] `Inventory::Intake::NfeXmlParser` → lines `{ description, ean, quantity, unit, unit_cost_cents }`
- [ ] `Inventory::Intake::Matcher` — match by EAN (if we add it later) or name search scoped to org
- [ ] `POST /api/v1/inventory/intake/nfe` (multipart XML) → `{ lines: [{ ..., match: { product_type, id, name, confidence } | null }] }`
- [ ] Fixtures: 2–3 real (anonymised) NF-e XMLs

**Acceptance:** parser specs; malformed XML → 422 `invalid_document`; cross-tenant matching spec.

---

## Phase 2 — Label photo → product draft (AI)

- [ ] `Catalog::Intake::LabelExtractor` — image to `Ai::Client` with a **strict JSON schema** for the target type (Beer: name, maker, style, abv, ibu, description; Wine: name, maker, style, …)
- [ ] Validate output against schema; unknown style/maker → return as text suggestion + existing matches, not new IDs
- [ ] `POST /api/v1/catalog/intake/label` (multipart image, `product_type`) → `{ draft: {...}, confidence, warnings: [] }`
- [ ] Gated by `Ai.enabled_for?`

**Acceptance:** spec with `Ai::FakeClient`; invalid JSON from model → 502 `ai_invalid_output`, no partial draft.

---

## Phase 3 — DANFE / paper invoice (AI)

- [ ] Same output as Phase 1 from a PDF/photo via vision extraction
- [ ] Reuse `Matcher`; mark every line `source: "ai"` so UI highlights it for review

**Acceptance:** eval set of 5 invoice photos in `spec/ai_evals/intake/` run manually with `bin/rails ai:eval[intake]`.

---

## Security notes

- Validate MIME by content, not extension (`marcel`)
- Uploaded text is untrusted: extracted strings are data, never instructions
- Strip EXIF/location from images before sending to the provider

---

## Manual steps

- [ ] None for Phase 1–2 (no migration). Optional `ean` column on stockable products → separate migration if adopted.

---

## Definition of done

- [ ] NF-e XML import works without AI
- [ ] Label photo produces a reviewable draft for Beer and Wine
- [ ] Nothing persisted without explicit confirmation through existing endpoints
- [ ] Swagger documented; React companion plan created

---

## References

- `app/models/product.rb` (`has_one_attached :image`)
- `app/controllers/api/v1/stock_adjustments_controller.rb`
- `app/services/inventory/adjust_stock.rb`
- [docs/context/inventory-stock.md](../context/inventory-stock.md)
