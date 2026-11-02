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
| Breached passwords | `devise-pwned_password` on every path that sets a password (registration, reset, staff set-password, settings). Not on sign-in. Reject when the Pwned Passwords count is at least 100. Timeout 2 seconds. If the service errors, accept the password and log the failure. Only the first 5 characters of the SHA-1 leave the server |
| Local denylist | Still reject the email local-part and the organization name. The breach list does not know the bar |
| New staff secret | Stop emailing a password. Email a single-use set-password link, same lifetime as the reset secret |
| Reset secret | One link, not a 6-digit code that logs the user in. Stored as a digest, expires in 15 minutes, deleted on use. It authorizes setting a password and does not issue a JWT |
| Unknown email | Forgot-password always returns 200 and sends mail only when the user exists |
| Change password | Require `current_password` except on the single-use reset link |
| Other sessions | On a successful password change, delete the user's other `allowlisted_jwts` |
| Impersonation | A support session cannot set a password. See [23](./23-support-impersonation.md) |
| MFA | Out of scope |

---

## Out of scope (v1)

- Forcing every current user to reset on deploy
- Checking Pwned Passwords on sign-in
- Refusing a password when the breach service is down
- Magic-link login for every visit
- Changing Argon2

---

## Phase 1 — Recovery no longer logs anyone in

Today `POST /auth/code` finds the plaintext 6-digit code and issues a JWT. That route goes away as a login.

- [ ] Forgot-password returns 200 for known and unknown emails. Mail goes out only when the user exists
- [ ] The mail carries a single-use link. The stored value is a digest. It expires in 15 minutes and is deleted when the new password is saved
- [ ] The link opens a set-password action. Success does not create a session. The person signs in afterwards with the new password
- [ ] An expired or reused link returns 422 and does not issue a JWT
- [ ] Rack::Attack throttles `POST /auth/password` and the set-password route by IP, tighter than the general 300-request bucket
- [ ] Specs: expired link, reused link, unknown email still 200, a valid link that does not appear in `allowlisted_jwts` until a real sign-in

**Acceptance:** a code from yesterday does not sign anyone in. Knowing the secret is not enough to enter the account. The database column is not the raw secret.

---

## Phase 2 — Choosing a password

- [ ] Minimum 12, the local denylist, and `devise-pwned_password` (`:pwned_password`, `min_password_matches` 100, `pwned_password_check_on_sign_in` false) on every path that sets `password`
- [ ] Spec with WebMock: a password seen at least 100 times is rejected. A timeout or HTTP error does not reject it. Sign-in does not call the service
- [ ] Update and settings require `current_password` when `password` is present. The single-use reset link does not
- [ ] Staff create sends a set-password link instead of `friendly_token.first(8)`
- [ ] Welcome mail no longer contains a password
- [ ] After a successful change, other allowlisted JWTs for that user are deleted. The current session can stay

**Acceptance:** `123123123` and a commonly breached password are rejected when setting a password. A settings change without `current_password` is 422. An old JWT from before the change is rejected. Sign-in of an existing password does not call Pwned Passwords.

---

## Phase 3 — Contract

- [ ] rswag for forgot-password (always 200), reset, and the current-password failure
- [ ] Locales `pt-BR`, `en`, `es` for `password_too_short`, `password_denied`, `password_pwned`, and `current_password_invalid`

---

## Manual steps

- [ ] None, unless the reset column needs a longer digest. If it does, `bin/rails db:migrate` and do not keep old plaintext codes

---

## Definition of done

- [ ] New passwords are at least 12 characters, not on the local denylist, and rejected when Pwned Passwords has seen them at least 100 times
- [ ] That breach check runs only when a password is set, and a failed call does not block the change
- [ ] The reset link expires, is single-use, is not stored raw, and does not issue a JWT
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
- `devise-pwned_password` (Pwned Passwords range API, k-anonymity)
