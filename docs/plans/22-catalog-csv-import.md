# Plan: Catalog CSV import

**Status:** not started  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — catalog CSV import](../../../ubuteco-react/docs/plans/22-catalog-csv-import.md)  
**Branch:** `feature/catalog-csv-import`  
**Priority:** P2  
**Depends on:** [01-multi-tenant](./01-multi-tenant.md), [09-inventory-stock](./09-inventory-stock.md)  
**Estimated effort:** 1 sprint

Scheduled after the AI track (plans 16–21) and before [03 Subscription plans](./03-subscription-plans.md). Platform hardening does not block it.

---

## Goal

Let an organization admin create many beers, drinks, wines, foods, and dishes from a CSV. Each row uses the same validations as the existing create endpoints. A preview lists what would be created and which rows would fail. Nothing is saved until the admin confirms.

---

## Product decisions (lock before coding)

| Decision | Choice (v1) |
|----------|-------------|
| Who | **ADMIN** of the current organization. Not cash register, waiter, kitchen, or super admin |
| Files | One CSV per product type. Header row required |
| Types | `beer`, `drink`, `wine`, `food`, `dish` |
| Create vs update | **Create only.** A name that already exists in the organization (case-insensitive) is a row error. The same name twice in the file: the second row errors |
| Missing maker or style | Row error. Do not create a maker, beer style, or wine style from the file |
| Maker / style match | Case-insensitive name. Maker is limited to the current organization. Beer style and wine style are the global catalogs |
| Dish ingredients | Foods already in the organization, or foods created earlier in the same confirmed import. Unknown food name is a row error. Do not create a food from a dish row |
| Import order | Foods before dishes when a dish names a new food. The other types are independent |
| Partial success | Each saved row is its own transaction. Later failures do not roll back earlier rows. The response says what was saved |
| Preview | `dry_run=1` runs the same checks and writes nothing |
| Price | Decimal in the organization currency (`12.50` or `12,50`). Stored with the existing `monetize :price_cents`. No currency column |
| Stock | Blank `quantity_stock` becomes `0` for beer, drink, wine, and food. Dishes have no stock column |
| Dates | `valid_until` is `YYYY-MM-DD`. Blank means no expiry |
| Encoding | UTF-8. A leading BOM is stripped. Delimiter is comma or semicolon, chosen from the header line |
| Limits | 1 MB, 500 data rows, one file per request. Over the limit: 422, nothing saved |
| Images | Out of scope |
| Tenant | `organization_id` comes from `Current.organization`. A column in the file is ignored |

---

## Out of scope (v1)

- Updating or deleting existing products
- Creating makers, styles, users, or tables
- `.xlsx` (export CSV from the spreadsheet)
- Photos, either embedded or by URL
- A background job. 500 rows stay in the request. Searchkick stays on its existing async callback

---

## Columns

Headers accept the English key or the Portuguese alias. Comparison is case-insensitive and ignores accents on the alias (`preco` and `preço` both work).

### Beer

| Column | Alias | Required |
|--------|-------|----------|
| `name` | `nome` | yes |
| `price` | `preco` | yes |
| `ibu` | `ibu` | yes |
| `quantity_stock` | `estoque` | no (blank → 0) |
| `abv` | `teor` | yes |
| `maker` | `fabricante` | yes, must already exist |
| `beer_style` | `estilo` | yes, must already exist |
| `description` | `descricao` | no |
| `valid_until` | `validade` | no |

### Drink

| Column | Alias | Required |
|--------|-------|----------|
| `name` | `nome` | yes |
| `price` | `preco` | yes |
| `quantity_stock` | `estoque` | no (blank → 0) |
| `description` | `descricao` | no |
| `flavor` | `sabor` | no |

### Wine

| Column | Alias | Required |
|--------|-------|----------|
| `name` | `nome` | yes |
| `price` | `preco` | yes |
| `abv` | `teor` | yes |
| `quantity_stock` | `estoque` | no (blank → 0) |
| `description` | `descricao` | yes |
| `vintage_wine` | `safra` | yes |
| `visual` | `visual` | yes |
| `ripening` | `amadurecimento` | yes |
| `grapes` | `uvas` | yes |
| `maker` | `fabricante` | yes, must already exist |
| `wine_style` | `estilo` | yes, must already exist |

Wine already requires `description`, `vintage_wine`, `visual`, `ripening`, and `grapes` on the model. The CSV does not relax that.

### Food

| Column | Alias | Required |
|--------|-------|----------|
| `name` | `nome` | yes |
| `price` | `preco` | yes |
| `quantity_stock` | `estoque` | no (blank → 0) |
| `valid_until` | `validade` | no |

### Dish

| Column | Alias | Required |
|--------|-------|----------|
| `name` | `nome` | yes |
| `price` | `preco` | yes |
| `ingredients` | `ingredientes` | no |

`ingredients` is a list inside the cell, separated by `|`. Each item is `Food name:quantity`. Quantity uses a dot or a comma and must be greater than 0.

```text
Pão francês:1|Queijo:0,2
```

The food match is case-insensitive and scoped to the organization. One food twice on the same dish is a row error (`food_id` is unique per dish).

---

## Phase 1 — Parse and validate

- [ ] `Catalog::CsvImport::Table` reads the file, strips the BOM, picks `,` or `;` from the header, and maps aliases to canonical keys
- [ ] Decimal parser accepts `12.50` and `12,50`. A thousands separator is a row error
- [ ] Unknown header, missing required header, empty file, and more than 500 data rows fail the whole file before any row is checked
- [ ] Row errors keep the spreadsheet line number (header is line 1)

**Acceptance:** parser specs for both delimiters, both decimal marks, a BOM, and a broken header. No database writes.

---

## Phase 2 — Create rows

- [ ] `Catalog::CsvImport::Importer` builds `Beer`, `Drink`, `Wine`, `Food`, or `Dish` with `organization_id` from `Current.organization`
- [ ] Maker and style lookups stay inside the rules above. A maker from another organization does not match
- [ ] Model validations are the row errors (`name`, `price`, wine presence, ingredient quantity)
- [ ] `dry_run=1` reports `would_create` and `errors` and leaves counts unchanged
- [ ] Without dry run, each valid row is saved in its own transaction. The response lists failures and does not pretend the failed rows were saved

**Acceptance:** specs for a valid beer, a missing style, a duplicate name, a cross-tenant maker, a dish whose food does not exist, a dish whose food does exist, and a dry run that does not change `Beer.count`.

---

## Phase 3 — Endpoint

- [ ] `POST /api/v1/catalog/imports` multipart `file`, `product_type`, optional `dry_run`
- [ ] `authorize! :create, Beer` (and the matching model for the requested type). Admin already has `:manage` on catalog records. Other roles receive 403
- [ ] Bad file: 422 `invalid_csv`. Unknown `product_type`: 422 `validation_error`
- [ ] Response JSON:

```json
{
  "dry_run": true,
  "created": 0,
  "failed": 1,
  "rows": [
    { "line": 3, "name": "Loba IPA", "status": "error", "errors": ["beer_style not found"] }
  ]
}
```

Successful rows use `"status": "created"` or `"would_create"`. Return failures plus a short list of created names (cap the created list at 500, which is also the file cap).

- [ ] rswag for the preview and the 403

**Acceptance:** request specs with `as` multipart (omit the JSON content type). Waiter and cash register get 403. A second import of the same file reports duplicates and does not create a second beer.

---

## Phase 4 — Templates

- [ ] `GET /api/v1/catalog/imports/template?product_type=beer` returns a UTF-8 CSV with the English headers and one example row
- [ ] The same action for `drink`, `wine`, `food`, and `dish`
- [ ] Example dish row uses the `|` ingredient format

**Acceptance:** the template for each type parses back through Phase 1 without a header error.

---

## Security notes

- The file is data. Cell text is assigned to attributes. It is not evaluated and it is not passed to the AI client
- MIME comes from content (`marcel`): `text/csv`, `text/plain`, or `application/vnd.ms-excel`, and the body must look like a header row
- Do not log the whole file. Log organization id, product type, created count, and failed count

---

## Manual steps

- [ ] None. No migration

---

## Definition of done

- [ ] Admin can preview and then create beers, drinks, wines, foods, and dishes from CSV
- [ ] Cash register, waiter, kitchen, and super admin cannot
- [ ] Another organization's maker or food never matches
- [ ] Swagger documents the import and the template
- [ ] React companion plan is in place

---

## References

- `app/controllers/api/v1/beers_controller.rb` (`create_params`)
- `app/controllers/api/v1/wines_controller.rb`, `drinks_controller.rb`, `foods_controller.rb`, `dishes_controller.rb`
- `app/models/product.rb` (`monetize :price_cents`, `validates :name, :price`)
- `app/models/wine.rb` (presence list), `app/models/dish_ingredient.rb` (quantity > 0, unique food per dish)
- `app/models/abilities/admin_ability.rb` (`can :manage` catalog, cannot create `BeerStyle` / `WineStyle`)
