---
phase: 01-foundations-safety-net
plan: 06
subsystem: testing
tags: [rails, system-tests, capybara, smoke, lexxy, fizzy-port]

requires:
  - phase: 01-02
    provides: account_cancellations migration so test-DB schema is current when system tests boot
  - phase: 01-03
    provides: 3-account fixtures so fixture loading does not fail when system tests load Rails
provides:
  - Fizzy-style SmokeTest covering signing in / creating an idea / voting / commenting
  - SystemTestHelper#sign_in_as: password-mode toggle + post-signin wait
  - SystemTestHelper#fill_in_lexxy: Lexxy-aware rich-text fill helper
affects: [02-roadmap-polish, 02-trending-feed, all future system test work]

tech-stack:
  added: []
  patterns:
    - "Lexxy fill pattern: find('lexxy-editor').set + execute_script setting the hidden input value"
    - "Capybara sign-in helpers must wait for the success flash before returning, otherwise the next visit races the cookie set"

key-files:
  created:
    - test/system/smoke_test.rb
  modified:
    - test/support/system_test_helper.rb
    - db/schema.rb
  deleted:
    - test/system/ideas_test.rb

key-decisions:
  - "Used fill_in_lexxy (Fizzy-style) instead of Rails' fill_in_rich_text_area because FeedbackBin uses the Lexxy editor, not Trix. The Rails helper calls editor.loadHTML which is a Trix-only API and throws JavaScript errors against Lexxy."
  - "Embedded an assert_text 'You have signed in successfully.' inside sign_in_as so Capybara waits for the redirect before returning. Without this wait, the next visit would race the session-cookie write."

patterns-established:
  - "One SmokeTest class with happy-path tests across multiple resources, not per-resource system test files (D-01)"
  - "Use ideas(:two) for vote-increment tests; ideas(:one) has a pre-existing shane vote per fixtures/votes.yml and clicking upvote there toggles OFF (Pitfall 6)"

requirements-completed: [FOUND-01]

duration: ~30min
completed: 2026-05-06
---

# Phase 01-06: Smoke Tests Summary

**Fizzy-style SmokeTest covering sign in / create idea / vote / comment, plus SystemTestHelper repairs (password-mode toggle, post-signin wait, Lexxy-aware rich-text fill).**

## Performance

- **Duration:** ~30 min (including diagnostic detour for the Lexxy editor)
- **Completed:** 2026-05-06
- **Tasks:** 1 (3 sub-actions: helper update, file deletion, smoke test creation)
- **Files touched:** 4 (1 created, 2 modified, 1 deleted)

## Accomplishments
- 4 smoke tests that lock in the four core happy paths
- `SystemTestHelper#sign_in_as` now matches the real magic-link-first form (clicks the password-mode toggle) and waits for the success flash so subsequent visits do not race the cookie set
- New `SystemTestHelper#fill_in_lexxy` helper that the Lexxy editor responds to
- Removed the blocked `test/system/ideas_test.rb` (1 active test + 4 commented-out tests waiting on Board UI that will not be built in Phase 1)
- Full system suite green: 9 runs, 19 assertions, 0 failures, 0 errors (smoke + authentication + password_resets)

## Task Commits

1. **Task 1: SystemTestHelper repairs + delete blocked ideas_test.rb + create smoke_test.rb** - `a6acd20` (test)

## Files Created/Modified
- `test/system/smoke_test.rb` (new) - 4 Fizzy-style happy-path system tests
- `test/support/system_test_helper.rb` - password-mode toggle in `sign_in_as`, `assert_text` wait, new `fill_in_lexxy` helper
- `test/system/ideas_test.rb` (deleted) - blocked TODO tests removed per D-03
- `db/schema.rb` - test-DB regeneration bumped the version stamp from `2026_03_30_000003` to `2026_04_20_140000` (the cancellations migration timestamp); finishes an in-flight detail from the 01-02 merge

## Decisions Made
- **Lexxy, not Trix.** Plan said to use `fill_in_rich_text_area` and explicitly NOT to use `fill_in_lexxy`, but FeedbackBin's `Gemfile` and `config/importmap.rb` confirm Lexxy is the rich-text editor. The Rails helper calls `editor.loadHTML` which is a Trix-only API and throws `Cannot read properties of undefined (reading 'loadHTML')`. Switched to a Fizzy-pattern `fill_in_lexxy` helper added to `SystemTestHelper`.
- **Wait inside `sign_in_as`.** Without `assert_text "You have signed in successfully."` after `click_button "Sign in"`, Capybara's next `visit` raced the sign-in cookie set, intermittently surfacing the unauthenticated branch of the comment form (and a separate latent bug with `sign_up_path` rather than `users_sign_up_path` in that branch).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Plan Wrong About Editor] Replaced `fill_in_rich_text_area` with `fill_in_lexxy`**
- **Found during:** Task 1 verification (smoke tests for create idea + comment failed with Trix-specific JavaScript error and rich-text-area locator lookup)
- **Issue:** Plan said to use Rails' built-in `fill_in_rich_text_area`. FeedbackBin uses Lexxy (`gem "lexxy"` in Gemfile, `pin "lexxy"` in importmap.rb), so the Rails helper's `this.editor.loadHTML(...)` call throws because Lexxy does not expose that API.
- **Fix:** Added `fill_in_lexxy(selector = "lexxy-editor", with:)` to `SystemTestHelper` (modeled on Fizzy's helper at `test/system/smoke_test.rb:98-102` of the Fizzy reference). Switched both rich-text fills in `smoke_test.rb` to use it.
- **Files modified:** `test/support/system_test_helper.rb`, `test/system/smoke_test.rb`
- **Verification:** All 4 smoke tests now pass; full system suite green (9/9).
- **Committed in:** `a6acd20` (Task 1 commit)

**2. [Rule 2 - Sync Race] Embedded post-signin wait inside `sign_in_as`**
- **Found during:** Task 1 verification (vote and comment smoke tests failed with `undefined local variable 'sign_up_path'`, indicating the comment form rendered the unauthenticated branch)
- **Issue:** `sign_in_as` returned immediately after `click_button "Sign in"`. The browser hadn't completed the POST + redirect by the time the next `visit` fired, so the new request had no session cookie. The page rendered as unauthenticated, hitting a separate latent bug at `app/views/comments/_form.html.erb:27` (the route is `users_sign_up_path`, not `sign_up_path`).
- **Fix:** Added `assert_text "You have signed in successfully."` inside `sign_in_as` so Capybara waits for the success flash before returning. The latent `sign_up_path` bug is no longer triggered by the smoke tests, but remains as a pre-existing issue for unauthenticated viewers (separate Phase 2+ cleanup).
- **Files modified:** `test/support/system_test_helper.rb`
- **Verification:** Tests pass deterministically across runs.
- **Committed in:** `a6acd20` (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (1 plan factual error, 1 sync-race repair)
**Impact on plan:** All tests pass and full system suite stays green. The Lexxy switch is a single helper line; the post-signin wait makes the helper deterministic, which the plan's success criteria implicitly require.

## Issues Encountered
- **Latent template bug:** `app/views/comments/_form.html.erb:27` uses `sign_up_path` instead of `users_sign_up_path`. Surfaces only for unauthenticated viewers; the smoke tests now bypass it because `sign_in_as` waits for the cookie. Pre-existing; not fixed in Phase 1.
- **Latent template bug:** `app/views/changelogs/index.html.erb:38-39` uses bare `pagy` (already noted in the 01-05 SUMMARY).

## User Setup Required
None.

## Next Phase Readiness
- Smoke layer is in place: any future polish or refactor that breaks sign in / create idea / vote / comment will surface in CI immediately.
- `fill_in_lexxy` is available for future system tests touching rich text.
- Wave 3 done; phase verification + code review can run next.

---
*Phase: 01-foundations-safety-net*
*Completed: 2026-05-06*
