---
phase: 06-admin-notifications
plan: 06
subsystem: ui
tags: [ideas, watch-toggle, aria-pressed, lucide, ghost-icon, smoke-test, css-cascade-layers]

requires:
  - phase: 06-admin-notifications
    provides: "Ideas::WatchesController, idea_watch_path routes, _watch_button.html.erb partial, watches.yml fixtures (from 06-01..06-05)"
provides:
  - "Ghost-icon watch toggle button on idea show wired to the existing Watch model via aria-pressed=true|false"
  - "watch-toggle.css ships [aria-pressed=\"true\"] filled state via OKLCH --color-primary token"
  - "i18n keys ideas.watches.watch_button.watch_action / unwatch_action / tooltip_off / tooltip_on"
  - "One end-to-end smoke test in test/system/smoke_test.rb covering the click->Watch.create flow"
affects: [future phases that toast/error UI for watch toggles will plug into ideas.watches.watch_button.* scope]

tech-stack:
  added: []
  patterns:
    - "Lazy turbo_frame placeholder mirrors the loaded shape (variant + size + class) so loading state is visually stable"
    - "[aria-pressed=...] attribute-selector pattern (mirrors votes.css filled state) for two-state icon buttons"
    - "Icon-only buttons pair lucide_icon with <span class=\"visually-hidden\"> for the screen-reader label"

key-files:
  created:
    - "app/assets/stylesheets/watch-toggle.css"
  modified:
    - "app/views/ideas/watches/_watch_button.html.erb"
    - "app/views/ideas/show.html.erb"
    - "config/locales/en.yml"
    - "test/system/smoke_test.rb"

key-decisions:
  - "[06-06]: i18n keys land at ideas.watches.watch_button.* (the partial's lazy-lookup scope) not the UI-SPEC literal ideas.watch.*; the conceptual SPEC nesting collides with how Rails resolves t('.foo') from app/views/ideas/watches/_watch_button.html.erb."
  - "[06-06]: Drop unused legacy keys ideas.watches.watch_button.watch / .watching after the partial stops referencing them; defer toast_on / toast_off / error keys to the future plan that wires their consumer UI -- bin/i18n-tasks health exits non-zero on unused keys per config/i18n-tasks.yml."
  - "[06-06]: Smoke test waits on assert_selector 'button[aria-label=\"Unwatch this idea\"]' (Capybara waits for the post-redirect Turbo Frame to settle) before asserting watched_by?; sleep-based waits are flaky and the UI flip is the contract we ship."

patterns-established:
  - "Watch toggle ghost-icon: variant: :ghost + size: :icon + class: 'watch-toggle' + aria-pressed + aria-label + visually-hidden span -- the canonical icon-button + screen-reader-label combo"

requirements-completed: [ADMN-02]

duration: 7m
completed: 2026-06-17
---

# Phase 06 Plan 06: Idea Show Watch-Button Wiring Summary

**Ghost-icon watch toggle adjacent to the vote button on idea show with aria-pressed bell/bell-off icons, OKLCH-tinted filled state via [aria-pressed="true"] selector, and a single end-to-end smoke test for the click->Watch.create flow.**

## Performance

- **Duration:** ~7 min
- **Started:** 2026-06-17T14:52:27Z
- **Completed:** 2026-06-17T14:59:42Z
- **Tasks:** 2
- **Files modified:** 4 (1 created, 3 edited) + 1 test file edited

## Accomplishments

- `app/views/ideas/watches/_watch_button.html.erb` upgraded to `variant: :ghost, size: :icon` with `aria-pressed` reflecting watched state (bell when watching, bell-off when not). Outer `dom_id` wrapper preserved so the create/destroy turbo_stream targets keep working.
- `app/views/ideas/show.html.erb` lazy turbo_frame placeholder mirrors the ghost-icon shape with `aria-busy="true"`, so the loading state matches the loaded state visually.
- `app/assets/stylesheets/watch-toggle.css` ships the filled-state styling via `[aria-pressed="true"]` attribute selector + OKLCH `--color-primary` token (no `!important`, properly layered in `@layer components`).
- `config/locales/en.yml` gains `watch_action` / `unwatch_action` / `tooltip_off` / `tooltip_on` keys under `ideas.watches.watch_button.*` (where the partial's lazy-lookup resolves).
- `test/system/smoke_test.rb` gains ONE new smoke test ("watching an idea via the bell button") asserting the click -> aria-label flip -> `idea.watched_by?(user)` path; lives in the smoke file (no `test/system/admin_notifications/` directory created, per project memory).

## Task Commits

1. **Task 1: ghost-icon watch toggle + aria-pressed + watch-toggle.css** - `5905187` (feat)
2. **Task 2: watch-toggle smoke test in test/system/smoke_test.rb** - `64f48bb` (test)

## Files Created/Modified

- `app/assets/stylesheets/watch-toggle.css` - New `.watch-toggle` component with `[aria-pressed="true"]` filled state and `--color-ink-light` default; SVG `color` driven by `--watch-toggle-color`.
- `app/views/ideas/watches/_watch_button.html.erb` - Upgraded to `variant: :ghost, size: :icon` with `aria-pressed` + `aria-label` + `visually-hidden` screen-reader label, bell / bell-off icon pair, preserves outer `<div id="<%= dom_id(idea, :watch_button) %>">` wrapper.
- `app/views/ideas/show.html.erb` - Lazy turbo_frame placeholder now uses `variant: :ghost, size: :icon, aria-busy: "true"` with `class: "watch-toggle"` and `visually-hidden` label.
- `config/locales/en.yml` - Replaces unused `ideas.watches.watch_button.watch` / `.watching` with `watch_action` / `unwatch_action` / `tooltip_off` / `tooltip_on`.
- `test/system/smoke_test.rb` - Adds one smoke test for the bell button.

## Decisions Made

- **i18n scope:** Plan referenced `ideas.watch.*` (singular) per UI-SPEC lines 112-119, but `_watch_button.html.erb` lives in `app/views/ideas/watches/` and Rails' lazy lookup resolves `t(".foo")` to `ideas.watches.watch_button.foo`. The conceptual SPEC nesting cannot be honored literally without breaking lazy resolution -- keys placed at the lazy-lookup scope.
- **i18n key minimisation:** Project memory note "i18n lazy lookup in private methods" + `bin/i18n-tasks health` exits non-zero on unused keys (per `config/i18n-tasks.yml` `ignore_unused`). Added only the 4 keys actually used in this plan (`watch_action`, `unwatch_action`, `tooltip_off`, `tooltip_on`); dropped previously-unused `watch` / `watching` (the partial no longer references them); `toast_on` / `toast_off` / `error` from UI-SPEC are deferred to the plan that wires their consumer UI.
- **Smoke test wait strategy:** Capybara `find().click` returns before the POST -> redirect -> turbo_frame reload finishes; rather than `sleep`, use `assert_selector 'button[aria-label="Unwatch this idea"]'` (the post-flip contract) which Capybara polls. This is also the visible UX contract the user experiences.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Deferred unused i18n keys `toast_on` / `toast_off` / `error` to keep `bin/i18n-tasks health` green**

- **Found during:** Task 1 (i18n verification)
- **Issue:** Plan said to add `watch_action`, `unwatch_action`, `tooltip_off`, `tooltip_on`, `toast_on`, `toast_off`, `error` per UI-SPEC lines 112-119. But `bin/i18n-tasks health` (also a plan acceptance criterion) exits 1 on unused keys per `config/i18n-tasks.yml` `ignore_unused`. The toast/error keys have no consumer in this plan.
- **Fix:** Added only the 4 keys this plan actually references (`watch_action`, `unwatch_action`, `tooltip_off`, `tooltip_on`). Toast/error keys deferred to the future plan that wires their consumer (toast UI, error rendering).
- **Files modified:** `config/locales/en.yml`
- **Verification:** `bin/i18n-tasks health` exits 0 with "Every translation is in use".
- **Committed in:** `5905187` (Task 1 commit)

**2. [Rule 3 - Blocking] Dropped legacy unused i18n keys `ideas.watches.watch_button.watch` / `.watching`**

- **Found during:** Task 1 (i18n verification)
- **Issue:** Existing partial used `t(".watch")` / `t(".watching")` (resolving to `ideas.watches.watch_button.watch` / `.watching`). After Task 1's upgrade, the partial uses only `unwatch_action` / `watch_action` -- legacy keys flagged as unused by `bin/i18n-tasks health`.
- **Fix:** Removed the two legacy keys from `config/locales/en.yml`. (The placeholder in `ideas/show.html.erb` uses `t(".watch")` resolving to `ideas.show.watch` -- a different key that is preserved.)
- **Files modified:** `config/locales/en.yml`
- **Verification:** `bin/i18n-tasks health` exits 0.
- **Committed in:** `5905187` (Task 1 commit)

**3. [Rule 1 - Bug] Smoke test needed Turbo-settled wait (assert_selector) instead of raw `assert ... watched_by?`**

- **Found during:** Task 2 (initial smoke test failed)
- **Issue:** `find('button[aria-label="Watch this idea"]').click` returns to Ruby before the form POST -> 302 redirect -> reloaded turbo_frame finishes. The immediate `@unvoted_idea.reload.watched_by?(@user)` saw nil (no Watch row yet). First run failed: "Expected nil to be truthy".
- **Fix:** Added `assert_selector 'button[aria-label="Unwatch this idea"]'` before the model assertion; Capybara polls the DOM for the post-flip button, which only appears once the turbo_frame has re-rendered the partial with `watched_by?(Current.user) == true`. This both stabilises the test and asserts the visible UX contract.
- **Files modified:** `test/system/smoke_test.rb`
- **Verification:** Test passes deterministically (reran multiple times, all green); full smoke suite passes (36 runs, 106 assertions, 0 failures).
- **Committed in:** `64f48bb` (Task 2 commit)

---

**Total deviations:** 3 auto-fixed (2 Rule 3 blocking i18n-health gates, 1 Rule 1 test-race fix)
**Impact on plan:** All auto-fixes were necessary to satisfy plan acceptance criteria (`bin/i18n-tasks health` exits 0 + smoke test must be deterministic). Scope unchanged; the deferred `toast_on` / `toast_off` / `error` i18n keys belong to a future plan that ships their consumer UI.

## Issues Encountered

- First run of the new smoke test failed because of the Capybara/Turbo race described in deviation #3. Resolved by adding `assert_selector` before the model assertion. Total dev cycles: 1 fail -> 1 fix -> green.

## Self-Check: PASSED

- `app/views/ideas/watches/_watch_button.html.erb`: FOUND, modified
- `app/views/ideas/show.html.erb`: FOUND, modified
- `app/assets/stylesheets/watch-toggle.css`: FOUND, created
- `config/locales/en.yml`: FOUND, modified
- `test/system/smoke_test.rb`: FOUND, modified
- Commit `5905187` (Task 1): FOUND in `git log`
- Commit `64f48bb` (Task 2): FOUND in `git log`

## Next Phase Readiness

- ADMN-02 D-07 ships: the bell toggle is live on idea show with the contracted ghost-icon variant + aria-pressed + bell/bell-off icons + OKLCH-tinted filled state.
- The watch-toggle component CSS API is stable (`--watch-toggle-color`); future plans can extend by overriding the variable.
- Deferred work: `toast_on` / `toast_off` / `error` i18n keys + their consumer UI (a toast helper or flash flow) remain for whoever picks up the next watch-related UI plan.

---
*Phase: 06-admin-notifications*
*Completed: 2026-06-17*
