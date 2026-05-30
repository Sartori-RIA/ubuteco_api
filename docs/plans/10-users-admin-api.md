# Plan: Users admin API (supporting UI)

**Status:** not started  
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
- `can_manage_self` allows `:manage` on own user (includes **destroy**).
- Kitchen/waiter/cash can open `/settings` and call `DELETE /users/:id` on themselves today.

---

## Phase 1 — Self-delete policy

- [ ] **Decision:** only org **`ADMIN`** may `destroy` their **own** account via self-service
- [ ] **`SUPER_ADMIN` cannot `destroy` self** — internal operator; deprovision via platform/ops or another super admin (future platform API), not org settings
- [ ] Update abilities:
  - `can :destroy, User, id: user.id` only when `user.admin?` (org admin role)
  - `cannot :destroy, User, id: user.id` for `SUPER_ADMIN`, kitchen, waiter, cash, customer
- [ ] Kitchen/waiter/cash: may `:update` self (profile), not `:destroy`
- [ ] Request specs per role (include super admin self-delete → 403)

---

## Phase 2 — Admin delete staff

- [ ] ADMIN can `:destroy` users in same `organization_id` (except last admin guard — optional)
- [ ] Cannot delete user from another org
- [ ] **SUPER_ADMIN** deleting users: platform scope only (other orgs / other super admins) — define in [01-multi-tenant](./01-multi-tenant.md) platform routes; never self-delete
- [ ] Soft delete (paranoia) already on User? — verify behavior

---

## Phase 3 — Role assignment

- [ ] ADMIN cannot assign `SUPER_ADMIN`
- [ ] Cannot demote self if sole admin (optional guard)
- [ ] Permitted roles list endpoint or document valid `role_id` values per org admin

---

## Phase 4 — Swagger & errors

- [ ] Document 403 on self-delete for non-admin
- [ ] Structured error code `account_deletion_forbidden`

---

## Definition of done

- [ ] API enforces delete policy independent of UI
- [ ] Specs: kitchen self-delete → 403; **super admin self-delete → 403**; org admin self-delete → allowed
- [ ] Front hides button except org ADMIN ([08-settings-account-deletion](../../../ubuteco-react/docs/plans/08-settings-account-deletion.md))

---

## References

- `app/models/abilities/admin_ability.rb`, `base_ability.rb`
- `app/controllers/api/v1/users_controller.rb`
