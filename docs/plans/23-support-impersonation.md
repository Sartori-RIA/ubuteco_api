# Plan: Support impersonation

**Status:** completed  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — support impersonation](../../../ubuteco-react/docs/plans/23-support-impersonation.md)  
**Branch:** `feature/support-impersonation`  
**Priority:** P2  
**Depends on:** [01-multi-tenant](./01-multi-tenant.md), [10-users-admin-api](./10-users-admin-api.md), [24-password-policy](./24-password-policy.md)  
**Estimated effort:** 1 sprint

Scheduled after the AI track and before [03 Subscription plans](./03-subscription-plans.md). Ship [24 Password policy](./24-password-policy.md) first. Platform hardening does not block it.

---

## Goal

A super admin can open the app as a user in organization A to reproduce a bug that only happens there. The support session never reads, returns, or changes that user's password. The session is short, explained, written down, and visible, so a support account cannot quietly rewrite the tenant.

---

## Product decisions (lock before coding)

| Decision | Choice (v1) |
|----------|-------------|
| Who may start | `SUPER_ADMIN` only |
| Who may be entered | A user with an organization. Never another `SUPER_ADMIN`. Never yourself |
| Password | Not read, not returned, not logged, not changed. The target password digest stays untouched |
| How the session is issued | A new JWT for the target user, with an `impersonation` claim and the support user id. The support user's own token stays valid and is what "leave" returns to |
| Length | 30 minutes from start. No refresh that extends it. `DELETE` ends it sooner and revokes that JWT |
| Reason | Required, 10–500 characters, stored |
| One at a time | A support user has at most one open session. Starting another returns 409 |
| Abilities | The request is authorized as the target user, so the bug can be reproduced. A denylist still applies |
| Denylist while impersonating | Password, email, role, user destroy, organization destroy, starting another impersonation, assigning `SUPER_ADMIN` |
| Other writes | Allowed, because the bug may be on a write path. Every mutating request is audited with the support user id |
| Notice | Email the target user and the organization admins when the session starts: who, when, organization, reason. No secrets in the mail |
| Visibility | Any super admin can list open and recent sessions |

---

## Out of scope (v1)

- Org admin impersonating their own staff
- A shared support password or a copied password
- Impersonation inside Sidekiq jobs
- Changing the target user into a super admin
- Hiding the session from the tenant

---

## Phase 1 — Session record

- [x] Migration `support_sessions`: `actor_id`, `user_id`, `organization_id`, `reason`, `jti`, `started_at`, `expires_at`, `ended_at`, timestamps. Index open sessions by `actor_id` where `ended_at` is null
- [x] `POST /api/v1/platform/impersonations` with `user_id` and `reason`. Returns the target JWT and the session id. 403 for anyone who is not a super admin. 422 for a missing reason, a super-admin target, or a user without an organization
- [x] The JWT is allowlisted like the others and expires at `expires_at` (30 minutes), not the normal one-day lifetime
- [x] `DELETE /api/v1/platform/impersonations/:id` sets `ended_at` and deletes that allowlisted JWT
- [x] `GET /api/v1/platform/impersonations` lists sessions for every super admin

**Acceptance:** the response body and the logs do not contain the target password or its digest. A second start by the same actor returns 409. Entering another super admin returns 422.

---

## Phase 2 — Request guard

- [x] `Current.impersonator` is the support user when the JWT carries the claim. `Current.user` and `Current.organization` stay the target, so abilities match that profile
- [x] Password and account routes reject the impersonation JWT with 403 `impersonation_forbidden`: `PUT /auth/reset_passwords`, user update when `password`, `email`, or `role_id` is present, user destroy, organization destroy
- [x] `append_info_to_payload` adds `impersonator_id` on these requests
- [x] Mutating requests (`POST`, `PUT`, `PATCH`, `DELETE`) write `support_session_id`, path, and status. Do not store the body
- [x] Ending the session or passing `expires_at` makes the JWT fail the allowlist

**Acceptance:** as the impersonated admin, a beer can be created and the audit row names the support user. The same session cannot change the password or the email. A normal login of the target user still works and is not this session.

---

## Phase 3 — Mail

- [x] `SupportSessionMailer` on the existing `mailers` queue
- [x] One mail to the target user and one to each organization `ADMIN`, in the organization locale
- [x] The mail says a super admin entered, the reason, and when it expires. It does not include a token

**Acceptance:** mailer spec covers start. No mail on a rejected start.

---

## Security notes

- Support never learns the password. Reproduction uses a separate short JWT
- The denylist is in the API, not only in the React banner
- `Abilities::SuperAdminAbility#organization_users_support` already `can :manage, User` for a platform organization. Do not add a password update through that ability. Impersonation is the only way into the tenant UI
- Rate-limit session starts (for example 10 per hour per actor) so a token cannot walk the whole user table unnoticed. The list and the emails are the other brake

---

## Manual steps

- [ ] `bin/rails db:migrate` for `support_sessions`

---

## Definition of done

- [x] Only a super admin can start a session, and only with a reason
- [x] The target password cannot be read or changed from that session
- [x] The session dies at 30 minutes or on leave, whichever comes first
- [x] Tenant admins are emailed, and every super admin can see the session
- [x] Mutating requests record the support user
- [x] Swagger documents start, show/list, and leave
- [x] React companion plan is in place

---

## References

- `app/models/abilities/super_admin_ability.rb`
- `app/controllers/api/v1/platform/base_controller.rb`
- `app/controllers/concerns/set_current_tenant.rb`
- `config/initializers/devise.rb` (JWT allowlist, one-day `expiration_time` for normal logins)
- `app/models/allowlisted_jwt.rb`
- [24-password-policy](./24-password-policy.md)
