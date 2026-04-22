---
phase: 01-foundations-safety-net
plan: 01
subsystem: config
tags: [rails, mailer, omniauth, env, self-hosted]

requires:
  - phase: none
    provides: baseline Rails app
provides:
  - Operator-controlled mailer from address via MAILER_FROM_ADDRESS env
  - Conditional OAuth provider registration so the app boots with zero OAuth credentials
  - OauthHelper#omniauth_provider_available? for view-level provider gating
  - Unit test coverage for ApplicationMailer default from fallback
affects: [01-02-cancellable-concern, 01-06-smoke-tests, deploy-config]

tech-stack:
  added: []
  patterns:
    - ENV.fetch with sensible fallback for deploy-level config (Fizzy pattern)
    - Conditional OmniAuth provider registration with Rails.application.credentials
    - View helper encapsulating provider availability so partials stay dumb

key-files:
  created:
    - app/helpers/oauth_helper.rb
    - test/mailers/application_mailer_test.rb
  modified:
    - app/mailers/application_mailer.rb
    - config/initializers/omniauth.rb
    - app/views/application/_oauth_providers.html.erb

key-decisions:
  - "Keep Google/Facebook registered in test env regardless of credentials so OmniAuth.test_mode mocks continue to work across 11 existing controller tests"
  - "No controller guard on /auth/* routes; OmniAuth handles unregistered provider attempts natively (out of scope per plan)"
  - "No new I18n keys; empty-provider state renders nothing with no explanatory copy per D-09 (zero config self-host experience)"

patterns-established:
  - "ENV-first config: ENV.fetch(VAR, fallback) for deploy-configurable values"
  - "Credential-gated middleware: Initializers check Rails.application.credentials.present? before registering optional integrations"
  - "Helper-gated view iteration: Views filter through a helper method so the helper is the single source of truth for availability"

requirements-completed: [FOUND-04]

duration: 9min
completed: 2026-04-22
---

# Phase 01 Plan 01: Config Production Blockers Summary

**Zero-config OAuth registration and ENV-driven mailer from address; FeedbackBin now boots for a self-hoster with no Google, Facebook, or MAILER_FROM_ADDRESS set, and the sign-in partial hides buttons for any unregistered provider.**

## Performance

- **Duration:** ~9 min
- **Started:** 2026-04-22T14:30:00Z
- **Completed:** 2026-04-22T14:39:36Z
- **Tasks:** 2
- **Files modified:** 3 modified, 2 created

## Accomplishments
- Replaced hardcoded `from@example.com` with `ENV.fetch("MAILER_FROM_ADDRESS", "FeedbackBin <support@feedbackbin.com>")`
- Gated Google and Facebook OmniAuth provider registration on credential presence (plus always-on in test env for mock compatibility)
- Added `OauthHelper#omniauth_provider_available?` and wired it into `_oauth_providers.html.erb` so the partial renders nothing when a provider is unregistered
- Covered the mailer fallback with a dedicated `ApplicationMailerTest` (1 assertion passing, 1 documented skip)

## Task Commits

Each task committed atomically:

1. **Task 1 RED: failing test for mailer from fallback** - `1328cbb` (test)
2. **Task 1 GREEN: ENV-based mailer from address** - `245cb5d` (feat)
3. **Task 2: conditional OAuth registration + view helper** - `418e5a9` (feat)

No REFACTOR commit needed on Task 1 (GREEN diff was a single-line literal replacement).

## Files Created/Modified
- `app/mailers/application_mailer.rb` - Swapped hardcoded from to `ENV.fetch("MAILER_FROM_ADDRESS", "FeedbackBin <support@feedbackbin.com>")`
- `config/initializers/omniauth.rb` - Conditional `provider :google_oauth2` / `provider :facebook` guarded on `creds.*.present?`, with `Rails.env.test?` escape hatch for existing OmniAuth mock tests
- `app/helpers/oauth_helper.rb` - New `OauthHelper#omniauth_provider_available?(provider)` returning true when the matching credential pair is present (or developer in non-prod)
- `app/views/application/_oauth_providers.html.erb` - `.select { |p| omniauth_provider_available?(p) }` filter so unregistered providers never render; removed the stale TODO comment per plan's literal replacement instruction
- `test/mailers/application_mailer_test.rb` - New test asserting the fallback from address, plus documented skipped test explaining class-load-time resolution

## Decisions Made
- **Test-env escape hatch in initializer.** The plan's literal `if creds.google_app_id.present? && creds.google_app_secret.present?` broke 3 pre-existing `Users::OmniauthControllerTest` tests that hit `/auth/google/callback` via OmniAuth mocks. Rather than register Google/Facebook with `nil` credentials in all envs (restoring the pre-plan boot behavior that D-09 explicitly wants gone), the initializer now reads `if Rails.env.test? || (creds.google_app_id.present? && creds.google_app_secret.present?)`. Prod and dev behavior matches the plan's intent (zero-config self-host); test env preserves the existing mock contract.
- **No controller-level guard on `/auth/*`.** Per plan, OmniAuth returns its native failure response for unregistered providers; adding a controller check is out of scope.
- **No new I18n key for "provider unavailable" copy.** D-09 is explicit that the self-host experience is "clean sign-in page", not "explain which providers aren't configured". Empty iteration renders zero buttons; that's the intended UX.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Added `Rails.env.test?` escape hatch to OmniAuth provider registration**
- **Found during:** Task 2 (OAuth conditional registration)
- **Issue:** Plan's exact initializer code registered Google/Facebook only when credentials were present, which is correct for prod/dev. But three existing tests in `test/controllers/users/omniauth_controller_test.rb` (`should handle previously connected identity account`, `cannot connect with account if connected to another identity`, `can connect to a social account when signed in and previously connected`) hit `/auth/google/callback` via `OmniAuth.config.test_mode` mocks. With Google unregistered, those requests redirected to `/` instead of `session_menu_url`, failing all three assertions. The plan's success criterion `bin/rails test exits 0 (no regression across the full suite)` was violated.
- **Fix:** Changed the two credential conditionals to `if Rails.env.test? || (creds.google_app_id.present? && creds.google_app_secret.present?)` and the matching Facebook line. Test env always registers both providers (using whatever nil/present values `Rails.application.credentials` yields) so `OmniAuth.test_mode` keeps capturing the callbacks; prod and dev behavior is unchanged from the plan's intent.
- **Files modified:** `config/initializers/omniauth.rb`
- **Verification:** `bin/rails test` went from `3 failures` to `889 runs, 0 failures, 0 errors, 1 skip`. `bin/rails test test/controllers/users/omniauth_controller_test.rb` passes all 11 tests. Rubocop and erb_lint both clean.
- **Committed in:** `418e5a9` (Task 2 commit)
- **Acceptance-criteria note:** The literal grep `grep -n 'if creds.google_app_id.present? && creds.google_app_secret.present?' config/initializers/omniauth.rb` no longer matches exactly because the line now reads `if Rails.env.test? || (creds.google_app_id.present? && creds.google_app_secret.present?)`. The semantic intent (conditional registration outside test) is fully preserved, and the broader grep `'creds.google_app_id.present? && creds.google_app_secret.present?'` does match. Same applies to the Facebook grep.

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** The fix is required to satisfy the plan's own "no test regressions" acceptance criterion. No scope creep; the change is additive (one `Rails.env.test? ||` per conditional) and preserves all D-09 intent for prod/dev.

## Issues Encountered
- Baseline tests in `Users::OmniauthControllerTest` depended on OmniAuth providers being registered at boot even with nil credentials, which conflicted with the plan's literal "only register when credentials present" implementation. Resolved via Rule 3 auto-fix above.

## User Setup Required
None for plan completion. **Operators deploying FeedbackBin to production must now either:**
- Set `MAILER_FROM_ADDRESS` env var to a DKIM/SPF-verified sender address (e.g. `"Acme <support@acme.com>"`), or accept the `"FeedbackBin <support@feedbackbin.com>"` fallback.
- Set `google_app_id` / `google_app_secret` and/or `facebook_app_id` / `facebook_app_secret` in `Rails.application.credentials` to enable OAuth sign-in buttons. With none set, the sign-in page renders only email/password (and developer provider in non-prod).

## Next Phase Readiness
- FOUND-04 is partially satisfied by this plan (mailer + OAuth blockers). The third FOUND-04 blocker (`Account.active?` backed by a Cancellable concern) is owned by plan `01-02-cancellable-concern`.
- No shared-file modifications (STATE.md, ROADMAP.md, REQUIREMENTS.md) performed; orchestrator owns those after wave completes.

## Self-Check: PASSED

- `app/mailers/application_mailer.rb` exists and contains the ENV.fetch line: FOUND
- `config/initializers/omniauth.rb` exists with conditional registration: FOUND
- `app/helpers/oauth_helper.rb` exists with `omniauth_provider_available?`: FOUND
- `app/views/application/_oauth_providers.html.erb` filters through the helper: FOUND
- `test/mailers/application_mailer_test.rb` exists: FOUND
- Commit `1328cbb` (test RED) in git log: FOUND
- Commit `245cb5d` (feat GREEN mailer) in git log: FOUND
- Commit `418e5a9` (feat OAuth conditional) in git log: FOUND
- `bin/rails test test/mailers/application_mailer_test.rb`: 2 runs, 1 assertion, 0 failures, 0 errors, 1 skip (PASS)
- `bin/rails test` full suite: 889 runs, 2348 assertions, 0 failures, 0 errors, 1 skip (PASS)
- `bin/rubocop` on touched files: no offenses (PASS)
- `bin/erb_lint app/views/application/_oauth_providers.html.erb`: no errors (PASS)

---
*Phase: 01-foundations-safety-net*
*Completed: 2026-04-22*
