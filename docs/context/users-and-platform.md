# Users, roles & platform admin

Stable reference for user management and super-admin platform routes. Plans: [10-users-admin-api](../plans/10-users-admin-api.md), [01-multi-tenant](../plans/01-multi-tenant.md). Role summary: [roles-and-access.md](./roles-and-access.md).

## Org-scoped users (`/api/v1/users`)

| Action | Who |
|--------|-----|
| CRUD staff in org | `ADMIN` (via `can :manage, User, organization_id:`) |
| Read/update own profile | All roles (except customer namespace rules) |
| Self-delete (`DELETE /users/:id` where `id == current_user`) | **`ADMIN` only** |
| Assign `SUPER_ADMIN` role | **Forbidden** — `role_assignment_forbidden` (403) |

### Self-delete policy

Enforced in **abilities + CanCan**, not only UI:

- `Abilities::BaseAbility#can_manage_self` — `can :destroy, User, id: user.id` only when `org_admin?(user)`
- `SuperAdminAbility` — `cannot :destroy, User, id: user.id` (super admin cannot delete self)
- Kitchen, waiter, cash register, customer — no self-delete
- On denied self-delete: `ApplicationController#account_deletion_denied?` → `account_deletion_forbidden` (403, structured JSON)

Org admin may delete **other** staff in the same org via `:manage` on `UsersController`.

### Role assignment guard

`UsersController#authorize_assignable_role!` blocks assigning `SUPER_ADMIN` on create/update — returns `role_assignment_forbidden`.

## Platform routes (`SUPER_ADMIN` only)

Namespace: `/api/v1/platform/...`

| Controller | Purpose |
|------------|---------|
| `Api::V1::Platform::OrganizationsController` | Cross-org org CRUD |
| `Api::V1::Platform::Organizations::UsersController` | Users within a platform-selected org |

`SuperAdminAbility::PLATFORM_CONTROLLERS` gates full platform `:manage` permissions. Outside platform controllers, super admin has global read/manage on catalog entities (beer/wine styles) but **operational catalog mutation is restricted** — read-only platform mode for menu entities in org context.

## Tenant rules (always)

- Org-scoped users must have `organization_id` set.
- **Never** accept client `organization_id` on create when `Current.organization` should define tenant — `UsersController#create_params` merges `organization_id: current_user.organization_id`.
- Cross-org access by ID → 403 — see `spec/security/cross_tenant/access_spec.rb`.

## Soft delete

`User` uses Paranoia (`acts_as_paranoid`). Destroy is soft delete.

## Common errors

| Code | HTTP | When |
|------|------|------|
| `account_deletion_forbidden` | 403 | Non-admin self-delete attempt |
| `role_assignment_forbidden` | 403 | Assigning `SUPER_ADMIN` |
| `validation_error` | 422 | Model validation failures |

## Key files

```
app/controllers/api/v1/users_controller.rb
app/controllers/api/v1/platform/
app/models/abilities/admin_ability.rb
app/models/abilities/super_admin_ability.rb
app/models/abilities/base_ability.rb
app/controllers/application_controller.rb  # account_deletion_denied?
```

## Testing

- Self-delete / role guard: `spec/controllers/api/v1/users_request_spec.rb`
- Cross-tenant users: `spec/security/cross_tenant/access_spec.rb`
- Platform: `spec/requests/api/v1/platform/organizations_spec.rb`

## AI pitfalls

- Do not allow kitchen/waiter self-delete — policy is API-enforced.
- Do not let org admin assign `SUPER_ADMIN`.
- Do not trust `organization_id` from request body on user create.
- Platform routes are not org-scoped the same way — check `SuperAdminAbility` and controller namespace before adding endpoints.
