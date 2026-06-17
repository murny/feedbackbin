---
phase: 06-admin-notifications
plan: 04
subsystem: notifications
tags: [notifications, unsubscribe, message-verifier, signed-token, can-spam, mailer, security, routes]

requires:
  - phase: 06-admin-notifications/06-02
    provides: IdeaCommentMailer + new_comment view (HTML and text) that this plan extends with footers
  - phase: 06-admin-notifications/06-03
    provides: Wave-3 readiness (admin actionable dashboard); no direct code dependency
provides:
  - UnsubscribesController#destroy_by_token (POST-only, allow_unauthenticated_access)
  - unsubscribe_destroy_by_token route at /unsubscribe/destroy_by_token (top-level, no auth, no account scope)
  - ApplicationHelper#unwatch_token_for(idea, recipient) for mailer-side signed-token generation
  - ApplicationMailer now exposes ApplicationHelper to mailer views via helper :application
  - CAN-SPAM unwatch footer rendered in IdeaCommentMailer (HTML + text) and IdeaStatusChangeMailer (HTML + text)
  - user_settings/watches routes (index, destroy, bulk_destroy) reserved for plan 06-05's controller
  - i18n keys: unsubscribes.show.*, idea_comment_mailer.new_comment.footer_*, idea_status_change_mailer.status_changed.footer_*
affects: [06-05 (user_settings/watches controller will land on routes provided here), 06-06 (final phase wiring)]

tech-stack:
  added: []
  patterns:
    - "Rails.application.message_verifier(:watch_unsubscribe).generate/verified for one-click unsubscribe tokens (precedent: via_magic_link.rb)"
    - "Raw <form method=\"post\"> in mailer HTML views (mailers lack protect_against_forgery? so ButtonComponent/button_to cannot be used)"
    - "skip_forgery_protection on a CSRF-free endpoint where the signed message_verifier token replaces the CSRF token as the action's authorization mechanism"
    - "Identical 410 Gone response for invalid signature / expired token / missing watch (T-06-03 enumeration mitigation)"
    - "helper :application on ApplicationMailer to expose ApplicationHelper to all mailer views"

key-files:
  created:
    - app/controllers/unsubscribes_controller.rb
    - app/views/unsubscribes/show.html.erb
    - app/views/unsubscribes/expired.html.erb
    - test/controllers/unsubscribes_controller_test.rb
  modified:
    - app/helpers/application_helper.rb
    - app/mailers/application_mailer.rb
    - app/views/idea_comment_mailer/new_comment.html.erb
    - app/views/idea_comment_mailer/new_comment.text.erb
    - app/views/idea_status_change_mailer/status_changed.html.erb
    - app/views/idea_status_change_mailer/status_changed.text.erb
    - config/routes.rb
    - config/locales/en.yml
    - test/mailers/idea_comment_mailer_test.rb
    - test/mailers/idea_status_change_mailer_test.rb

key-decisions:
  - "Used raw <form method=\"post\"> in mailer HTML views instead of Elements::ButtonComponent(method: :post) because ActionMailer views do not have access to protect_against_forgery? (the Rails form helpers require it)."
  - "Added skip_forgery_protection only: :destroy_by_token to UnsubscribesController so the form submitted from the email succeeds without a CSRF token; the signed message_verifier token already binds the action to a specific watch row and prevents tampering."
  - "Routed the POST endpoint via post 'unsubscribe/destroy_by_token', as: :unsubscribe_destroy_by_token (named route) instead of resource :unsubscribe ... post :destroy_by_token so the route helper matches the unsubscribe_destroy_by_token_path/_url name expected by the plan acceptance criteria; Rails generates destroy_by_token_unsubscribe_path for the resource form, which would not match."
  - "Added skip_before_action :require_account, :ensure_signup_completed on the destroy_by_token action so the link works in standalone mode (also defends against account-slug misconfiguration)."
  - "Added helper :application to ApplicationMailer so unwatch_token_for is visible in all mailer views."

patterns-established:
  - "One-click signed-token unsubscribe pattern: Rails.application.message_verifier(:<purpose>) generate in helper, verify in controller, identical 410 response for all failure paths."
  - "Raw HTML form rendering in mailer HTML views when a Rails form helper is unavailable (mailers lack the helpers that the form helpers expect)."

requirements-completed: [ADMN-03, ADMN-02]

duration: 16m
completed: 2026-06-17
---

# Phase 6 Plan 4: Signed-Token Unsubscribe Endpoint + Notification Mailer Footers Summary

**POST-only signed-token unwatch endpoint with allow_unauthenticated_access, ApplicationHelper#unwatch_token_for, and CAN-SPAM unwatch footers in both IdeaCommentMailer and IdeaStatusChangeMailer (HTML + text).**

## Performance

- **Duration:** 16 min
- **Started:** 2026-06-17T14:21:48Z
- **Completed:** 2026-06-17T14:37:55Z
- **Tasks:** 2 (both TDD)
- **Files modified/created:** 13

## Accomplishments
- UnsubscribesController#destroy_by_token verifies a Rails.application.message_verifier(:watch_unsubscribe) token with a {watch_id, user_id, idea_id} payload and toggles Watch.watching to false. Identical 410 Gone + expired template for invalid signature, expired token, and missing-watch (T-06-03 enumeration mitigation).
- POST-only routing at /unsubscribe/destroy_by_token (T-06-01: defeats email-client GET prefetch). GET is not routed.
- ApplicationHelper#unwatch_token_for(idea, recipient) generates the 30-day signed token from inside the mailer view.
- Notification email footers (HTML + text) in both IdeaCommentMailer and IdeaStatusChangeMailer carry: footer_reason (with idea title interpolation), POST unwatch link to /unsubscribe/destroy_by_token, and a "Manage all watched ideas" link to /user_settings/watches.
- user_settings/watches index, destroy, and bulk_destroy routes added (the controller arrives in plan 06-05; helpers resolve now so the mailer footer and the unsubscribe show page do not raise NoMethodError).
- i18n keys per UI-SPEC under unsubscribes.show.*, idea_comment_mailer.new_comment.footer_*, idea_status_change_mailer.status_changed.footer_*. bin/i18n-tasks health passes clean.

## Task Commits

Each TDD pair is committed as RED → GREEN:

1. **Task 1 RED: failing tests for UnsubscribesController** - `6c98538` (test)
2. **Task 1 GREEN: controller + routes + views + helper + locales** - `a6c1762` (feat)
3. **Task 2 RED: failing footer tests for both notification mailers** - `a314496` (test)
4. **Task 2 GREEN: footer markup + helper exposure + skip_forgery_protection** - `ac7d0a6` (feat)

## Files Created/Modified

Created:
- `app/controllers/unsubscribes_controller.rb` - one-click unsubscribe endpoint with signed-token verification
- `app/views/unsubscribes/show.html.erb` - confirmation page with "Watch again" and "Manage all watched ideas" CTAs
- `app/views/unsubscribes/expired.html.erb` - generic 410 page reused for invalid/expired/missing-watch
- `test/controllers/unsubscribes_controller_test.rb` - 5 tests covering valid/invalid/expired/missing-watch/unauthenticated/GET-not-routable

Modified:
- `app/helpers/application_helper.rb` - added unwatch_token_for(idea, recipient)
- `app/mailers/application_mailer.rb` - added helper :application so mailer views see ApplicationHelper
- `app/views/idea_comment_mailer/new_comment.html.erb` - appended unwatch footer (raw <form method="post">)
- `app/views/idea_comment_mailer/new_comment.text.erb` - appended unwatch footer (bare URLs)
- `app/views/idea_status_change_mailer/status_changed.html.erb` - appended unwatch footer
- `app/views/idea_status_change_mailer/status_changed.text.erb` - appended unwatch footer
- `config/routes.rb` - POST /unsubscribe/destroy_by_token; user_settings/watches index/destroy/bulk
- `config/locales/en.yml` - new unsubscribes.show.* and *_mailer footer_* keys (alphabetically sorted)
- `test/mailers/idea_comment_mailer_test.rb` - +3 footer assertions
- `test/mailers/idea_status_change_mailer_test.rb` - +3 footer assertions

## Decisions Made
- Used raw `<form method="post">` in HTML mailer views instead of `Elements::ButtonComponent(method: :post)` / `button_to`. Mailer views run in an `ActionMailer::Base` context that does not include `RequestForgeryProtection`, so `protect_against_forgery?` is undefined; any Rails form helper that emits a CSRF token raises `NoMethodError`. The raw form preserves the POST-only invariant required by T-06-01 / D-10.
- Added `skip_forgery_protection only: :destroy_by_token` to `UnsubscribesController`. The signed `message_verifier(:watch_unsubscribe)` token already binds the action to a specific (watch_id, user_id, idea_id) tuple with an expiry, so it replaces CSRF as the authorization mechanism. Threat model T-06-01 and T-06-US-01 are still mitigated.
- Named the route via `post "unsubscribe/destroy_by_token", as: :unsubscribe_destroy_by_token` so the helper matches the plan's expected `unsubscribe_destroy_by_token_path`. The `resource :unsubscribe ... post :destroy_by_token` form would have generated `destroy_by_token_unsubscribe_path`, which would have broken the mailer views and the controller test.
- Skipped `require_account` and `ensure_signup_completed` on the destroy_by_token action so the link works without an account context (defense-in-depth against account-slug misconfiguration; account context is normally injected via the AccountSlug::Extractor middleware in the mailer URL).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] HTML mailer footer cannot use `Elements::ButtonComponent` with `method: :post`**
- **Found during:** Task 2 GREEN (running mailer tests)
- **Issue:** The plan and PATTERNS specified rendering the unwatch link as `Elements::ButtonComponent.new(variant: :link, href: ..., method: :post)`. This delegates to `button_to`, which calls `protect_against_forgery?`. ActionMailer views do not include `RequestForgeryProtection`, so the call raised `NoMethodError: undefined method 'protect_against_forgery?'` and broke every mailer view that used the component.
- **Fix:** Replaced the `Elements::ButtonComponent` invocation with a raw `<form action="..." method="post" style="display:inline;"><button type="submit" style="...">Unwatch this idea</button></form>` in both HTML mailer views, and added `skip_forgery_protection only: :destroy_by_token` to `UnsubscribesController` so the form submitted from the email succeeds without a CSRF token.
- **Files modified:** app/views/idea_comment_mailer/new_comment.html.erb, app/views/idea_status_change_mailer/status_changed.html.erb, app/controllers/unsubscribes_controller.rb
- **Verification:** All 15 mailer tests + 5 controller tests pass; grep `method="post"` in both HTML views returns 1 each; routes show POST-only.
- **Committed in:** `ac7d0a6` (Task 2 GREEN)

**2. [Rule 2 - Missing Critical] ApplicationMailer did not expose ApplicationHelper to mailer views**
- **Found during:** Task 2 GREEN (`unwatch_token_for` raised `undefined method` from mailer template)
- **Issue:** Mailers do not automatically include `ApplicationHelper`. The helper added in Task 1 was invisible from mailer ERB.
- **Fix:** Added `helper :application` to `ApplicationMailer`.
- **Files modified:** app/mailers/application_mailer.rb
- **Verification:** Helper is callable from all mailer views; mailer tests assert tokens are encoded into URLs.
- **Committed in:** `ac7d0a6` (Task 2 GREEN)

**3. [Rule 3 - Blocking] Plan acceptance grep `user_settings_watches` returns 2, not 3**
- **Found during:** Task 1 GREEN (running acceptance checks)
- **Issue:** Plan expected `bin/rails routes | grep user_settings_watches` to return >= 3. Rails generates the destroy helper as singular (`user_settings_watch`), so only `bulk_user_settings_watches` and `user_settings_watches` match the plural substring (count of 2). All three routes exist.
- **Fix:** None required — verified by URL-path grep: `bin/rails routes | grep -E "/user_settings/watches"` returns 3 (index GET, destroy DELETE, bulk DELETE).
- **Files modified:** none
- **Verification:** Routes are present and correctly named per Rails convention.
- **Committed in:** n/a (no change)

**4. [Rule 1 - Bug] `ActiveSupport::MessageVerifier` default JSON serializer returns string-keyed payloads, plan accessed via symbols**
- **Found during:** Task 1 GREEN (first run of valid-token test returned 410 instead of 200)
- **Issue:** Plan's `payload[:watch_id]` would always be nil because `MessageVerifier#verified` returned a `Hash` with string keys (default JSON serializer), not a `HashWithIndifferentAccess`.
- **Fix:** Inserted `payload = payload.with_indifferent_access` before the `Watch.find_by(...)` lookup. The literal Watch.find_by line (required by acceptance) is unchanged.
- **Files modified:** app/controllers/unsubscribes_controller.rb
- **Verification:** Valid-token test now returns 200 and toggles watching to false.
- **Committed in:** `a6c1762` (Task 1 GREEN)

**5. [Rule 3 - Blocking] `assert_template` not available**
- **Found during:** Task 1 GREEN (controller tests)
- **Issue:** Plan tests used `assert_template`, but the project does not include `rails-controller-testing`, so the helper raised `NoMethodError`.
- **Fix:** Switched assertions to `assert_match` on a unique substring from the rendered locale value (`"been unsubscribed"`, `"This unsubscribe link has expired"`). The intent (verify which template rendered) is preserved.
- **Files modified:** test/controllers/unsubscribes_controller_test.rb
- **Verification:** All 5 controller tests pass.
- **Committed in:** `a6c1762` (Task 1 GREEN)

**6. [Rule 3 - Blocking] `assert_raises(ActionController::RoutingError) { get "/unsubscribe/destroy_by_token" }` did not raise in integration tests**
- **Found during:** Task 1 GREEN (GET-not-routable assertion)
- **Issue:** Rails integration tests do not propagate routing failures as RoutingError; the unrouted GET returned a 404 response instead, so the raise-based assertion failed.
- **Fix:** Asserted at the route layer instead: `assert_raises(ActionController::RoutingError) { Rails.application.routes.recognize_path("/unsubscribe/destroy_by_token", method: :get) }`. This proves no GET route is defined.
- **Files modified:** test/controllers/unsubscribes_controller_test.rb
- **Verification:** Test passes; `bin/rails routes | grep unsubscribe | grep -E '^\s*GET\s'` returns 0 lines.
- **Committed in:** `a6c1762` (Task 1 GREEN)

---

**Total deviations:** 6 auto-fixed (3 Rule 1 bugs, 1 Rule 2 missing-critical, 2 Rule 3 blocking)
**Impact on plan:** All deviations were necessary to make the plan's intent work against the actual Rails/ActionMailer environment. No security or functionality scope was reduced; the mailer footer still POSTs only, the controller still mitigates T-06-01 / T-06-03 / T-06-US-01, and the signed-token contract is unchanged.

## Issues Encountered
- The plan's HTML footer pattern (`Elements::ButtonComponent` with `method: :post`) cannot work inside an ActionMailer view because `button_to` requires `protect_against_forgery?`. Resolved by switching to raw `<form method="post">` and skipping forgery protection on the receiving action.
- `Rails.application.message_verifier(:watch_unsubscribe).verified(...)` returns string-keyed hashes by default. Resolved by calling `with_indifferent_access` on the payload before lookup.
- `assert_template` is not available in this project (no `rails-controller-testing` gem). Switched to `assert_match` on locale-derived substrings.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- **Ready for plan 06-05:** the `user_settings/watches` routes (index, destroy, bulk_destroy) are wired and the URL helpers resolve in tests and mailer views. Plan 06-05 only needs to add the `UserSettings::WatchesController` + its views + tests; it MUST NOT re-add the routes.
- **Ready for plan 06-06:** the unwatch footer + endpoint are live in both notification mailers, so the final phase wiring can rely on them.
- No new blockers introduced.

## Self-Check: PASSED
- File `app/controllers/unsubscribes_controller.rb`: FOUND
- File `app/views/unsubscribes/show.html.erb`: FOUND
- File `app/views/unsubscribes/expired.html.erb`: FOUND
- File `app/helpers/application_helper.rb` (with `unwatch_token_for`): FOUND
- File `app/mailers/application_mailer.rb` (with `helper :application`): FOUND
- File `test/controllers/unsubscribes_controller_test.rb` (5 tests): FOUND
- Commit `6c98538` (Task 1 RED): FOUND
- Commit `a6c1762` (Task 1 GREEN): FOUND
- Commit `a314496` (Task 2 RED): FOUND
- Commit `ac7d0a6` (Task 2 GREEN): FOUND

---
*Phase: 06-admin-notifications*
*Completed: 2026-06-17*
