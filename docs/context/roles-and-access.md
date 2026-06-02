# Roles and access — API

CanCanCan abilities are the source of truth. This doc helps humans and AI predict behavior — always verify in `app/models/abilities/`.

## Role names

Stored on `users.role_id` → `roles.name`:

- `SUPER_ADMIN`
- `ADMIN`
- `KITCHEN`
- `WAITER`
- `CASH_REGISTER`
- `CUSTOMER`

## Tenant rules

- Org-scoped roles must have `user.organization_id` set.
- Abilities typically use `user.organization_id` to scope reads/writes.
- **Never** accept client-supplied `organization_id` for create on tenant-owned records when `Current.organization` should define the tenant (see multi-tenant plan).

## SUPER_ADMIN

- Platform routes under `Api::V1::Platform::*`
- Can list/view organizations and cross-org data where abilities allow
- Operational catalog mutation is restricted (read-only platform mode for menu entities)

## ADMIN

- Manage organization settings, users in org, full menu and orders
- Can update `operational_status` (kitchen open/closed) and org profile fields permitted in controller

## KITCHEN / WAITER / CASH_REGISTER

- Operational roles scoped to their organization
- Kitchen: queue read/update when org is `open`
- Operational status toggle: permitted for these roles + admin (see kitchen ability)

## CUSTOMER

- Limited self-service / ordering capabilities per product rules

## Testing access

- Request specs with `auth_header(user)` factory helpers
- Cross-tenant specs: user from org A must not access org B records by ID

## Frontend mirror

React guards in `ubuteco-react/src/app/_lib/auth-roles.ts` and `AuthGuard` — UX only, not security.
