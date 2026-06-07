# Plan: Users admin API (supporting UI)

**Status:** completed  
**Project:** ubuteco_api  
**Companion:** [ubuteco-react — users UI](../../../ubuteco-react/docs/plans/07-users-ui.md), [account deletion policy](../../../ubuteco-react/docs/plans/08-settings-account-deletion.md)  
**Priority:** P1  
**Depends on:** [01-multi-tenant](./01-multi-tenant.md)  
**Estimated effort:** 0.5 sprint (API gaps only; CRUD largely exists)

---

## Goal

API rules that match org admin UX: manage staff users, prevent non-admins from deleting accounts (self or others), and safe role assignment.

---

## Current state

- `UsersController`: CRUD + search index; org scoped via abilities.
- Self-delete restricted to org `ADMIN`; structured `account_deletion_forbidden` on forbidden self-delete.
- Org admin cannot assign `SUPER_ADMIN` role.

---

## Phase 1 — Self-delete policy

- [x] **Decision:** only org **`ADMIN`** may `destroy` their **own** account via self-service
- [x] **`SUPER_ADMIN` cannot `destroy` self** — internal operator; deprovision via platform/ops or another super admin (future platform API), not org settings
- [x] Update abilities:
  - `can :destroy, User, id: user.id` only when org admin role
  - `cannot :destroy, User, id: user.id` for `SUPER_ADMIN`, kitchen, waiter, cash, customer
- [x] Kitchen/waiter/cash: may `:update` self (profile), not `:destroy`
- [x] Request specs per role (include super admin self-delete → 403)

---

## Phase 2 — Admin delete staff

- [x] ADMIN can `:destroy` users in same `organization_id` (except last admin guard — optional, deferred)
- [x] Cannot delete user from another org
- [ ] **SUPER_ADMIN** deleting users: platform scope only (other orgs / other super admins) — define in [01-multi-tenant](./01-multi-tenant.md) platform routes; never self-delete
- [x] Soft delete (paranoia) already on User

---

## Phase 3 — Role assignment

- [x] ADMIN cannot assign `SUPER_ADMIN`
- [ ] Cannot demote self if sole admin (optional guard)
- [ ] Permitted roles list endpoint or document valid `role_id` values per org admin

---

## Phase 4 — Swagger & errors

- [ ] Document 403 on self-delete for non-admin
- [x] Structured error code `account_deletion_forbidden`

---

## Definition of done

- [x] API enforces delete policy independent of UI
- [x] Specs: kitchen self-delete → 403; **super admin self-delete → 403**; org admin self-delete → allowed
- [x] Front hides button except org ADMIN ([08-settings-account-deletion](../../../ubuteco-react/docs/plans/08-settings-account-deletion.md))

---

## References

- `app/models/abilities/admin_ability.rb`, `base_ability.rb`
- `app/controllers/api/v1/users_controller.rb`
