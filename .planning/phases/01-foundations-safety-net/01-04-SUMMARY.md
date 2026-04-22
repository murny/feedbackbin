---
phase: 01-foundations-safety-net
plan: 04
subsystem: testing
tags: [rails, minitest, concerns, sorting, filtering, testing]

requires:
  - phase: 01-foundations-safety-net
    provides: ModelSortable and Sortable concerns (existing, untested)
provides:
  - Unit test coverage for ModelSortable.sort_by_params and sortable_columns
  - Integration test coverage for Sortable controller concern (sort_column and sort_direction)
  - Test-level mitigations for T-04-01 (SQL column injection) and T-04-02 (direction injection)
affects: [COMP-06 FilterBar, ROAD polish, admin dashboards, any future sorting/filtering work]

tech-stack:
  added: []
  patterns:
    - ActionDispatch::IntegrationTest pattern for controller concern coverage (via host controller)
    - @controller method invocation after integration request to assert concern behavior

key-files:
  created:
    - test/controllers/concerns/sortable_test.rb
  modified:
    - test/models/concerns/model_sortable_test.rb

key-decisions:
  - "Use Idea as the test subject for ModelSortable (primary consumer per app/models/idea.rb:6)"
  - "Use IdeasController as the integration target for Sortable (includes the concern, exercises sort_column/sort_direction)"
  - "Leave the TODO comment in app/models/concerns/model_sortable.rb:9 untouched, dedupe work is explicitly out of scope"
  - "Do not add helper_method :sort_column/:sort_direction view-exposure tests (view-layer coverage, out of scope)"

patterns-established:
  - "Controller concern tests live in test/controllers/concerns/ and use ActionDispatch::IntegrationTest with a host controller (follows test/controllers/concerns/current_timezone_test.rb precedent)"
  - "Threat-model mitigations are enforced at the test layer via explicit injection-payload cases (e.g. params: { sort: 'drop_table' })"

requirements-completed: [FOUND-03]

duration: 2min
completed: 2026-04-22
---

# Phase 01 Plan 04: Sorting/Filtering Tests Summary

**12 new tests (5 ModelSortable unit + 7 Sortable integration) close the FOUND-03 coverage gap and lock in SQL-injection mitigations for ?sort= and ?direction= params.**

## Performance

- **Duration:** 2 min
- **Started:** 2026-04-22T14:37:10Z
- **Completed:** 2026-04-22T14:39:54Z
- **Tasks:** 2
- **Files modified:** 2 (1 created, 1 replaced)

## Accomplishments

- Replaced the 7-line TODO stub in `test/models/concerns/model_sortable_test.rb` with 5 real unit tests covering valid column, invalid column fallback, blank column, nil column, and default `sortable_columns` output.
- Added new `test/controllers/concerns/sortable_test.rb` with 7 integration tests covering `sort_column` defaults, valid values, invalid-column rejection, custom default, and `sort_direction` defaults, valid asc, and invalid-value rejection.
- Documented the T-04-01 (SQL column injection via `?sort=`) and T-04-02 (direction injection via `?direction=`) mitigations as live test cases so later phases cannot regress the `presence_in` filter.
- Plan-specific rubocop and test runs both green; no changes to production code.

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace ModelSortable TODO with unit tests** - `78269cd` (test)
2. **Task 2: Add integration tests for Sortable controller concern** - `6920cbf` (test)

_Note: Tasks were declared `tdd="true"` in the plan, but the system under test (ModelSortable and Sortable) already exists and is in production use. The plan's explicit purpose is retroactive coverage for untested code, so each task is a single `test(...)` commit (no separate GREEN) in line with that intent._

## Files Created/Modified

- `test/controllers/concerns/sortable_test.rb` - New integration test for the Sortable controller concern; 7 tests against IdeasController covering both sort_column and sort_direction branches.
- `test/models/concerns/model_sortable_test.rb` - Replaced the TODO stub with 5 unit tests against `Idea.sort_by_params` and `Idea.sortable_columns`.

## Decisions Made

- **Idea as ModelSortable subject:** `Idea` includes `ModelSortable` on line 6 of `app/models/idea.rb` and has diverse columns (title, created_at, votes_count), making it the highest-signal subject. Fixtures already exist in `test/fixtures/ideas.yml` and `Current.account = accounts(:feedbackbin)` from the global setup is sufficient (no explicit per-test setup required).
- **IdeasController as Sortable integration point:** `IdeasController#index` calls `sort_column(Idea)` and `sort_direction` directly on line 24 of `app/controllers/ideas_controller.rb`, so a single `get ideas_url` request is enough to populate `@controller.params` and exercise both methods.
- **ActionDispatch::IntegrationTest base class:** Needed to drive a real request cycle so `@controller.params` is populated. `test/controllers/concerns/current_timezone_test.rb` set the precedent for this directory layout.
- **`sign_in_as(users(:shane))` variant:** The integration-test helper from `test/test_helpers/session_test_helper.rb:8`, not the Capybara system-test variant (avoids Pitfall 1 from RESEARCH.md).
- **TODO in `app/models/concerns/model_sortable.rb:9` left in place:** The plan action explicitly scopes out the dedupe between model and controller concerns; that work is tracked separately.
- **No helper_method view-layer tests:** View exposure is a separate coverage concern per the plan's scope boundary.

## Deviations from Plan

None. The plan executed exactly as written, both task actions copied the specified test file contents verbatim and produced the expected green runs.

## Issues Encountered

- **Environmental: 24 pre-existing errors from untracked files in the worktree root (`test/controllers/admin/changelogs_controller_test.rb`, `test/controllers/admin/changelogs/publications_controller_test.rb`).** These files exist on disk from a prior branch state of the worktree but are not tracked in git, not part of commit `c5f32c7` (the expected base), and not part of this plan's scope. They depend on migrations and fixtures (a `draft` changelog fixture, a `roadmap_public` column, etc.) that are likewise not present in this base. Running the full `bin/rails test` suite picks them up via filesystem scan and they fail to load fixtures. Per the SCOPE BOUNDARY and destructive_git_prohibition rules, I did not remove or modify them. Verification on the specific plan files (`bin/rails test test/models/concerns/model_sortable_test.rb test/controllers/concerns/sortable_test.rb`, plus `test/controllers/ideas_controller_test.rb` and `test/models/idea_test.rb` as neighbors) is all green: 38 runs, 66 assertions, 0 failures, 0 errors.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- FOUND-03 test coverage is now in place, `ModelSortable` and `Sortable` concerns have explicit unit and integration tests, so COMP-06 (FilterBar), ROAD polish, and admin dashboard work can iterate on sorting/filtering logic with a safety net.
- Threat-model mitigations T-04-01 and T-04-02 are now asserted by tests; SQL column/direction injection via query params will fail CI if the `presence_in` filter is ever removed or weakened.
- No blockers for the next plan in the phase.

## Self-Check: PASSED

- FOUND: test/models/concerns/model_sortable_test.rb (modified, 19 line insertion)
- FOUND: test/controllers/concerns/sortable_test.rb (created, 52 lines)
- FOUND commit: 78269cd (Task 1 - ModelSortable tests)
- FOUND commit: 6920cbf (Task 2 - Sortable integration tests)
- VERIFIED: `bin/rails test test/models/concerns/model_sortable_test.rb` -> 5 runs, 5 assertions, 0 failures, 0 errors
- VERIFIED: `bin/rails test test/controllers/concerns/sortable_test.rb` -> 7 runs, 8 assertions, 0 failures, 0 errors
- VERIFIED: `bin/rubocop test/models/concerns/model_sortable_test.rb test/controllers/concerns/sortable_test.rb` -> 2 files inspected, no offenses

---
*Phase: 01-foundations-safety-net*
*Completed: 2026-04-22*
