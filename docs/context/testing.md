# Testing patterns — API

How to add and run specs in ubuteco_api. CI runs the same suite as local `bundle exec rspec` (see [workflow-plans-and-git.md](../workflow-plans-and-git.md)).

## Run commands

```bash
bundle exec rspec                              # full suite
bundle exec rspec spec/requests/order_lifecycle_spec.rb
bundle exec rspec spec/security/cross_tenant/
bin/ci                                         # RuboCop + Brakeman + bundler-audit + RSpec + OpenAPI drift
```

Requires Postgres (and OpenSearch for Searchkick specs). See [dev-setup.md](../dev-setup.md).

## Spec layout

| Directory | Purpose |
|-----------|---------|
| `spec/requests/` | HTTP integration (preferred for API behaviour) |
| `spec/requests/api/v1/*_spec.rb` | rswag specs — generate OpenAPI |
| `spec/controllers/api/v1/` | Controller/request specs (legacy patterns) |
| `spec/models/` | Model validations, AASM, stock logic |
| `spec/services/` | Service object unit tests |
| `spec/security/cross_tenant/` | **Required** for tenant-scoped resources |
| `spec/support/` | Helpers, Searchkick, Sidekiq, SimpleCov |

## Auth helpers

Included via `spec/support/helpers/headers.rb`:

```ruby
get api_v1_order_path(order), headers: auth_header(user)
post path, params: body.to_json, headers: auth_header(admin)
```

Factories: `spec/factories/` — traits like `:waiter`, `:kitchen`, `:open` on orders.

Role factories create users with correct `organization_id` — use separate orgs for cross-tenant tests.

## Request spec pattern

Mirror an existing file in the same area:

```ruby
require "rails_helper"

RSpec.describe "Feature name", type: :request do
  let(:organization) { create(:organization) }
  let(:admin) { organization.user }

  it "returns structured errors on validation failure" do
    post api_v1_users_path,
         params: { email: nil }.to_json,
         headers: auth_header(admin)

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["errors"].first).to include("code" => "validation_error")
  end
end
```

## Cross-tenant specs (mandatory for new org-scoped resources)

For every new tenant-owned resource, add cases to `spec/security/cross_tenant/`:

- User from org A must **not** show/update/destroy org B record by ID → `403`
- Create must not attach to another org via param injection

Existing coverage: `access_spec.rb`, `orders_create_spec.rb`, `search_spec.rb`.

## rswag / OpenAPI

Canonical flow:

1. Add or extend `spec/requests/api/v1/<resource>_spec.rb` with `require 'swagger_helper'`
2. Document paths, parameters, and `schema '$ref' => '#/components/schemas/errors_response'` for 422
3. Regenerate: `bundle exec rake openapi:refresh` (or `rswag:specs:swaggerize` + `openapi:sync_docs`)
4. Verify: `bundle exec rake openapi:drift_check`

Schemas live in `spec/swagger_helper.rb`. Committed artifacts: `swagger/v1/swagger.yaml`, `docs/swagger.yaml`.

**After any API contract change:** update rswag spec + run drift check before PR.

## Searchkick

- Test support: `spec/support/searchkick.rb` — callbacks inline in tests
- Cross-tenant search: `spec/security/cross_tenant/search_spec.rb`
- Search unavailable: `spec/requests/search_unavailable_spec.rb`

## Structured error assertions

Prefer asserting `code` and optional `field`:

```ruby
expect(response.parsed_body.dig("errors", 0, "code")).to eq("account_deletion_forbidden")
```

Not bare string arrays — legacy format is migrated.

## Coverage

SimpleCov via `spec/support/simplecov.rb`. Codecov in CI — avoid dropping coverage on changed areas without reason.

## AI checklist for new features

- [ ] Request spec for happy path + main failure
- [ ] Cross-tenant case if org-scoped
- [ ] Service spec if non-trivial domain logic
- [ ] rswag update if public API contract changed
- [ ] `openapi:drift_check` passes
- [ ] Mirror patterns from nearest existing spec file
