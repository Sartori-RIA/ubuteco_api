# Plan: Password policy

**Status:** not started  
**Project:** ubuteco_api (primary)  
**Companion:** [ubuteco-react — password policy](../../../ubuteco-react/docs/plans/24-password-policy.md)  
**Branch:** `feature/password-policy`  
**Priority:** P1  
**Depends on:** [10-users-admin-api](./10-users-admin-api.md)  
**Estimated effort:** 1 sprint

Scheduled before [23 Support impersonation](./23-support-impersonation.md) and before subscription. The reset code is a login, not only a formality.

---

## Goal

Make a stolen session or a guessed reset code insufficient to keep or take an account. Length and hashing stay the control. Character-class rules (one symbol, one number) are not added.

---

## What is wrong today

Checked in the current code:

| Gap | Where |
|-----|--------|
| Minimum length is 8. `123123123` is accepted. No denylist | `config/initializers/devise.rb` `password_length = 8..128`. Devise `:validatable` checks length only |
| A new staff user with an organization and no password gets 8 characters from `Devise.friendly_token`, and that password is emailed | `User#set_initial_data`, `User#send_welcome` |
| The reset code is 6 digits, stored in plaintext on `users.reset_password_token` | `User#generate_code`, `PasswordsController#create` |
| `POST /auth/code` signs the user in when the code matches. It does not check `reset_password_sent_at` (the 1 hour in Devise is unused here) and it does not clear the code | `CodeValidationsController` |
| That route is not throttled. Rack::Attack only slows `POST /auth/sign_in` and `POST /auth/sign_up` (5 requests / 20 seconds) | `config/initializers/rack_attack.rb` |
| Unknown email on forgot-password returns 404, so the endpoint lists accounts | `PasswordsController#create` |
| Changing the password does not require the current password | `UsersController` permits `:password`. `ResetPasswordsController` permits only `:password` |
| JWTs live 1 day and password change does not revoke them. Revocation is only `DELETE /auth/sign_out` | `devise.rb` `expiration_time` and `revocation_requests` |
| Argon2 is already the hasher | `User` devise `:argon2`. Keep it |

There is no `:lockable` and no idle timeout. The login throttle resets every 20 seconds, so it slows guessing and does not lock the account.

---

## Product decisions (lock before coding)

| Decision | Choice (v1) |
|----------|-------------|
| Minimum length | 12. Maximum stays 128. Existing shorter passwords keep working until the next change |
| Composition rules | None. Do not require a symbol or a number |
| Denylist | Reject a short built-in list (`123123123`, `password`, the email local-part, and the same class of obvious values). No external breach API in v1 |
| New staff secret | Stop emailing a password. Email a single-use set-password link, same lifetime as the reset code |
| Reset code | Store only a digest. 20 random bytes, or keep a short code only if it is throttled, expires in 15 minutes, and is deleted on use. Prefer the link |
| Unknown email | Forgot-password always returns 200 and sends mail only when the user exists |
| Change password | Require `current_password` except on the single-use reset link |
| Other sessions | On a successful password change, delete the user's other `allowlisted_jwts` |
| Impersonation | A support session cannot set a password. See [23](./23-support-impersonation.md) |
| MFA | Out of scope |

---

## Out of scope (v1)

- Forcing every current user to reset on deploy
- Have I Been Pwned or another live breach lookup
- Magic-link login for every visit
- Changing Argon2

---

## Phase 1 — Reset and throttle

- [ ] Forgot-password returns 200 for known and unknown emails
- [ ] The secret in the mail is single-use, expires in 15 minutes, and is stored as a digest
- [ ] `POST /auth/code` checks the expiry, then deletes the secret before it issues a JWT
- [ ] Rack::Attack throttles `POST /auth/password` and `POST /auth/code` by IP, tighter than the general 300-request bucket
- [ ] Specs: expired code, reused code, unknown email still 200, throttle

**Acceptance:** a code from yesterday does not sign anyone in. The database column is not the raw code.

---

## Phase 2 — Choosing a password

- [ ] Minimum 12, plus the denylist, on every path that sets `password` (registration, reset, user create, user update, settings)
- [ ] Update and settings require `current_password` when `password` is present. The single-use reset link does not
- [ ] Staff create sends a set-password link instead of `friendly_token.first(8)`
- [ ] Welcome mail no longer contains a password
- [ ] After a successful change, other allowlisted JWTs for that user are deleted. The current session can stay

**Acceptance:** `123123123` is rejected. A settings change without `current_password` is 422. An old JWT from before the change is rejected.

---

## Phase 3 — Contract

- [ ] rswag for forgot-password (always 200), reset, and the current-password failure
- [ ] Locales `pt-BR`, `en`, `es` for `password_too_short`, `password_denied`, and `current_password_invalid`

---

## Manual steps

- [ ] None, unless the reset column needs a longer digest. If it does, `bin/rails db:migrate` and do not keep old plaintext codes

---

## Definition of done

- [ ] New passwords are at least 12 characters and not on the denylist
- [ ] The reset secret expires, is single-use, and is not stored raw
- [ ] Forgot-password does not reveal whether the email exists
- [ ] Code and forgot-password routes are throttled
- [ ] Password change revokes the user's other JWTs and requires the current password outside the reset link
- [ ] No mail contains a reusable password
- [ ] React companion plan is in place

---

## References

- `config/initializers/devise.rb`
- `config/initializers/rack_attack.rb`
- `app/models/user.rb` (`generate_code`, `set_initial_data`)
- `app/controllers/passwords_controller.rb`
- `app/controllers/code_validations_controller.rb`
- `app/controllers/reset_passwords_controller.rb`
- `app/controllers/api/v1/users_controller.rb`
- `app/models/allowlisted_jwt.rb`
