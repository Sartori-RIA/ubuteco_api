# Plan: Catalog CSV import

**Status:** not started  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — catalog CSV import](../../../ubuteco-react/docs/plans/22-catalog-csv-import.md)  
**Branch:** `feature/catalog-csv-import`  
**Priority:** P2  
**Depends on:** [01-multi-tenant](./01-multi-tenant.md), [09-inventory-stock](./09-inventory-stock.md)  
**Estimated effort:** 1–1.5 sprints

Scheduled after the AI track (plans 16–21) and before [03 Subscription plans](./03-subscription-plans.md). Platform hardening does not block it.

---

## Goal

An organization admin uploads a CSV. The API stores the file, enqueues a Sidekiq job, and returns immediately. The job creates beers, drinks, wines, foods, or dishes. When it finishes, the admin who started it gets an email. If any line failed, the email names that line and why. A status endpoint tells the UI whether the import is queued, running, finished, or failed, and when a queued import is expected to start.

---

## Product decisions (lock before coding)

| Decision | Choice (v1) |
|----------|-------------|
| Who | **ADMIN** of the current organization only. Cash register, waiter, kitchen, and super admin receive 403 |
| Execution | Sidekiq, queue `imports`. The request does not create products |
| One at a time | An organization may have one import in `queued` or `running`. A second upload returns 409 until that one finishes |
| Retry | `retry: 0`. A retry would create the rows that already succeeded a second time |
| Files | One CSV per product type. Header row required. Headers are the English keys below. A Portuguese header is an unknown column and rejects the file before enqueue |
| Types | `beer`, `drink`, `wine`, `food`, `dish` |
| Create vs update | **Create only.** A name that already exists in the organization (case-insensitive) is a row error. The same name twice in the file: the second row errors |
| Missing maker or style | Row error. Do not create a maker, beer style, or wine style from the file |
| Maker / style match | Case-insensitive name. Maker is limited to the current organization. Beer style and wine style are the global catalogs |
| Dish ingredients | Foods already in the organization. Unknown food name is a row error. Do not create a food from a dish row |
| Import order | Foods before dishes when a dish names a new food. The other types are independent |
| Partial success | Each saved row is its own transaction. A later row error does not roll back earlier rows. The job still finishes as `completed` |
| Job crash | An unexpected exception sets `failed`. Rows saved before the crash stay saved. The email says the import stopped and lists what had already been saved |
| Price | Decimal in the organization currency (`12.50` or `12,50`). Stored with the existing `monetize :price_cents`. No currency column |
| Stock | Blank `quantity_stock` becomes `0` for beer, drink, wine, and food. Dishes have no stock column |
| Dates | `valid_until` is `YYYY-MM-DD`. Blank means no expiry |
| Encoding | UTF-8. A leading BOM is stripped. Delimiter is comma or semicolon, chosen from the header line |
| Limits | 1 MB, 500 data rows. Over the limit: 422, nothing enqueued |
| File retention | Active Storage holds the CSV until the job finishes, then the blob is purged. The row log stays in the database |
| Images | Out of scope |
| Tenant | `organization_id` comes from `Current.organization`. A column in the file is ignored |

---

## Out of scope (v1)

- Updating or deleting existing products
- Creating makers, styles, users, or tables
- `.xlsx`
- Photos, either embedded or by URL
- A synchronous preview that writes a dry-run result. Header and file checks happen before enqueue. Row results arrive from the job, the log, and the email
- Header aliases in Portuguese

---

## Columns

Headers are English, case-insensitive (`Name` and `name` match). Any other header rejects the file with 422 `invalid_csv` and does not enqueue.

### Beer

| Column | Required |
|--------|----------|
| `name` | yes |
| `price` | yes |
| `ibu` | yes |
| `quantity_stock` | no (blank → 0) |
| `abv` | yes |
| `maker` | yes, must already exist |
| `beer_style` | yes, must already exist |
| `description` | no |
| `valid_until` | no |

### Drink

| Column | Required |
|--------|----------|
| `name` | yes |
| `price` | yes |
| `quantity_stock` | no (blank → 0) |
| `description` | no |
| `flavor` | no |

### Wine

| Column | Required |
|--------|----------|
| `name` | yes |
| `price` | yes |
| `abv` | yes |
| `quantity_stock` | no (blank → 0) |
| `description` | yes |
| `vintage_wine` | yes |
| `visual` | yes |
| `ripening` | yes |
| `grapes` | yes |
| `maker` | yes, must already exist |
| `wine_style` | yes, must already exist |

Wine already requires `description`, `vintage_wine`, `visual`, `ripening`, and `grapes` on the model. The CSV does not relax that.

### Food

| Column | Required |
|--------|----------|
| `name` | yes |
| `price` | yes |
| `quantity_stock` | no (blank → 0) |
| `valid_until` | no |

### Dish

| Column | Required |
|--------|----------|
| `name` | yes |
| `price` | yes |
| `ingredients` | no |

`ingredients` is a list inside the cell, separated by `|`. Each item is `Food name:quantity`. Quantity uses a dot or a comma and must be greater than 0.

```text
Pão francês:1|Queijo:0.2
```

The food match is case-insensitive and scoped to the organization. One food twice on the same dish is a row error.

---

## Status

`CatalogImport` statuses:

| Status | Meaning |
|--------|---------|
| `queued` | Row saved, job not started |
| `running` | Job picked it up |
| `completed` | Job finished. `failed_rows` may be greater than zero |
| `failed` | Job raised. The import did not finish |

`estimated_start_at` is set only while `queued`. It is `Time.current + jobs_ahead * median_runtime`. `jobs_ahead` is the number of `imports` jobs waiting in front of this one, including any `running` import. `median_runtime` is the median of `(finished_at - started_at)` over the last 20 imports that reached `completed` or `failed`. With no history, `estimated_start_at` is null and the UI says the import is in the queue without a clock time. The value is an estimate, recomputed on each `GET`, not a promise.

While `running`, the record stores `processed_rows` and `total_rows`.

---

## Phase 1 — Parse

- [ ] `Catalog::CsvImport::Table` reads the file, strips the BOM, picks `,` or `;` from the header, and accepts only the English keys
- [ ] Decimal parser accepts `12.50` and `12,50`. A thousands separator is a row error
- [ ] Unknown header, missing required header, empty file, and more than 500 data rows raise before any product is built
- [ ] Row errors keep the spreadsheet line number (header is line 1)

**Acceptance:** parser specs for both delimiters, both decimal marks, a BOM, an English header, and a rejected Portuguese header. No database writes.

---

## Phase 2 — Job, log, and mail

- [ ] Migration `catalog_imports`: `organization_id`, `user_id`, `product_type`, `status`, `total_rows`, `created_rows`, `failed_rows`, `processed_rows`, `error_message`, `enqueued_at`, `started_at`, `finished_at`, `row_log` jsonb (default `[]`), timestamps. Index `(organization_id, status)`
- [ ] `has_one_attached :file`. Purged in an `ensure` after the job finishes
- [ ] `Catalog::CsvImportJob`, queue `:imports`, `retry: 0`. Add `imports` to `config/sidekiq.yml` (the worker only runs listed queues)
- [ ] The job sets `Current.organization`, marks `running`, creates each valid row in its own transaction, appends `{ line, name, status, errors }` to `row_log`, then marks `completed`
- [ ] On exception, mark `failed`, store `error_message`, keep the rows already written
- [ ] `CatalogImportMailer` to `user.email`, delivered with `deliver_later` on the existing `mailers` queue. Subject and body in the organization locale (`pt-BR`, `en`, `es`)
- [ ] The finished email states the type, how many rows were created, and how many failed. Each failed line is listed with its cause. A `failed` job says the import stopped and includes `error_message` plus any rows already created
- [ ] Do not enqueue a second import for the same organization while one is `queued` or `running`

**Acceptance:** job spec with a two-row file where the second row has a missing style. One beer exists, `row_log` has the line number and the cause, and the mailer is enqueued with that line. A raised error mid-file marks `failed` and does not retry. Cross-tenant maker does not match.

---

## Phase 3 — Endpoints

- [ ] `POST /api/v1/catalog/imports` multipart `file` and `product_type`. Admin only (`authorize! :create` on the matching catalog model). Returns **202** `{ id, status, estimated_start_at }`
- [ ] `GET /api/v1/catalog/imports` lists the current organization's imports, newest first
- [ ] `GET /api/v1/catalog/imports/:id` returns status, counts, `enqueued_at`, `started_at`, `finished_at`, `estimated_start_at`, `error_message`, and `row_log`. Another organization gets 404
- [ ] Bad file or unknown `product_type`: 422, no row, no job. Busy organization: 409
- [ ] `GET /api/v1/catalog/imports/template?product_type=beer` (and the other four types) returns a UTF-8 CSV with the English headers and one example row. The dish example uses the `|` ingredient format
- [ ] rswag for 202, 409, 403, and the show payload

**Acceptance:** waiter and cash register get 403. Admin show includes `estimated_start_at` while queued and null when there is no finished import to measure. Template for each type parses back through Phase 1.

---

## Security notes

- Cell text is assigned to attributes. It is not evaluated and it is not passed to the AI client
- MIME comes from content (`marcel`): `text/csv`, `text/plain`, or `application/vnd.ms-excel`, and the body must look like a header row
- Do not put the CSV body in the mail or in Rails logs. Log organization id, import id, product type, and counts
- The status endpoints are the same admin check as the upload

---

## Manual steps

- [ ] `bin/rails db:migrate` for `catalog_imports`
- [ ] Restart Sidekiq so it loads the `imports` queue

---

## Definition of done

- [ ] Only an organization admin can enqueue an import
- [ ] The job runs on Sidekiq and the upload request does not create products
- [ ] The status endpoint reports queued, running, completed, and failed, plus a start estimate when one can be computed
- [ ] The admin receives an email when the job ends. Failed lines include the line number and the cause
- [ ] Another organization's maker or food never matches
- [ ] Swagger documents the import, the status, and the template
- [ ] React companion plan is in place

---

## References

- `app/sidekiq/embed_product_job.rb` (job style, `sidekiq_options queue:`)
- `config/sidekiq.yml` (queues the worker actually runs)
- `app/mailers/user_mailer.rb`, `app/mailers/application_mailer.rb`
- `app/controllers/api/v1/beers_controller.rb` (`create_params`) and the wine, drink, food, and dish controllers
- `app/models/product.rb`, `app/models/wine.rb`, `app/models/dish_ingredient.rb`
- `app/models/abilities/admin_ability.rb` (`can :manage` catalog, cannot create `BeerStyle` / `WineStyle`)
