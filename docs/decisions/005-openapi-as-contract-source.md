# ADR 005: OpenAPI (rswag) as contract source of truth

**Status:** Accepted  
**Date:** 2026 (documented from plan 08)

## Context

AI-assisted development and the React frontend both need a reliable API contract. Undocumented controller changes cause drift and broken clients.

## Decision

- **Canonical spec:** `swagger/v1/swagger.yaml`, generated from rswag request specs.
- **Published copy:** `docs/swagger.yaml` synced for GitHub Pages Swagger UI.
- **CI enforcement:** `rake openapi:drift_check` fails if committed YAML differs after regenerate.
- **Workflow:** after contract changes → update `spec/requests/api/v1/*_spec.rb` → `rake openapi:refresh` → commit both YAML files.

Agents and humans must check existing routes/spec before inventing endpoints.

## Consequences

- New public endpoints require rswag coverage (or explicit plan exception).
- `bin/ci` includes OpenAPI drift check.
- Release process references synced spec — see [release-process.md](../release-process.md).

## References

- [docs/plans/08-api-contract-and-ci.md](../plans/08-api-contract-and-ci.md)
- [docs/context/api-conventions.md](../context/api-conventions.md)
- `lib/tasks/openapi.rake`, `spec/swagger_helper.rb`
