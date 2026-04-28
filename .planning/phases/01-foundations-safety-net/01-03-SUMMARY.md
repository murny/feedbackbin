---
phase: 01-foundations-safety-net
plan: 03
subsystem: testing
tags: [rails, multi-tenancy, isolation, fixtures, security, minitest]

requires:
  - phase: 01-02
    provides: account_cancellations migration so model tests load full schema
provides:
  - cleanstate account fixture (third tenant for D-11 3-account pattern)
  - acme-scoped board/idea/comment/vote fixtures
  - 7 cross-account isolation tests proving belongs_to default scoping
affects: [01-05, 01-06, future tenant-scoped phases]

tech-stack:
  added: []
  patterns:
    - "Cross-account isolation tests via accounts(:tenant).association queries (no Current.account switching)"
    - "Every fixture row carries an explicit account: key (Pitfall 6 prevention)"

key-files:
  created: []
  modified:
    - test/fixtures/accounts.yml
    - test/fixtures/boards.yml
    - test/fixtures/ideas.yml
    - test/fixtures/comments.yml
    - test/fixtures/votes.yml
    - test/models/idea_test.rb
    - test/models/comment_test.rb
    - test/models/vote_test.rb
    - test/models/board_test.rb

key-decisions:
  - "Tests query through accounts(:acme).ideas/comments/votes association rather than reassigning Current.account, per RESEARCH Pitfall 3"
  - "Scoped BoardTest#ordered to accounts(:feedbackbin).boards.ordered because Board.ordered has no account default_scope and the new acme_one fixture leaked into the global ordering"

patterns-established:
  - "Isolation tests live inline with the model test, not in a separate test/isolation/ directory (D-06)"
  - "3-account fixture pattern (feedbackbin, acme, cleanstate) matches D-11 and unblocks 01-05 seeds"

requirements-completed: [FOUND-02]

duration: 18min
completed: 2026-04-28
---

# Phase 01-03: Multi-Tenant Isolation Tests Summary

**Inline cross-account assertions on Idea/Comment/Vote model tests, backed by acme-scoped fixtures and a 3-account fixture pattern.**

## Performance

- **Duration:** ~18 min (sequential inline execution)
- **Completed:** 2026-04-28
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments
- Three accounts in fixtures: `feedbackbin`, `acme`, `cleanstate`
- One acme-scoped row each for boards, ideas, comments, votes (every row with explicit `account:`)
- 3 isolation tests on `IdeaTest` covering forward and reverse scope queries plus the acme-side find
- 2 isolation tests each on `CommentTest` and `VoteTest` covering scope inclusion and `RecordNotFound` on cross-account `find`
- Full suite stays green: 958 runs / 2516 assertions / 0 failures / 0 errors / 1 skip

## Task Commits

1. **Task 1: Add cleanstate account and acme-scoped fixtures** - `1f7b76f` (test)
2. **Task 2: Add cross-account isolation tests for Idea, Comment, Vote** - `5560096` (test)

## Files Created/Modified
- `test/fixtures/accounts.yml` - added `cleanstate` account row
- `test/fixtures/boards.yml` - added `acme_one` board scoped to acme
- `test/fixtures/ideas.yml` - added `acme_one` idea scoped to acme
- `test/fixtures/comments.yml` - added `acme_one` comment scoped to acme
- `test/fixtures/votes.yml` - added `acme_one` vote scoped to acme
- `test/models/idea_test.rb` - 3 isolation tests appended
- `test/models/comment_test.rb` - 2 isolation tests appended
- `test/models/vote_test.rb` - 2 isolation tests appended
- `test/models/board_test.rb` - scoped `ordered` test to `accounts(:feedbackbin).boards.ordered`

## Decisions Made
- Used association-scoped queries (`accounts(:acme).ideas`, etc.) per RESEARCH Pitfall 3 to avoid `Current.account` switching that leaks state between tests
- Scoped `BoardTest#test_ordered_scope_returns_boards_alphabetically` through `accounts(:feedbackbin).boards.ordered` rather than `Board.ordered`, because the existing scope has no account `default_scope` and the new fixture would otherwise pollute global ordering

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Test Regression] Scoped BoardTest#ordered through the account association**
- **Found during:** Task 2 verification (full suite run after fixture additions)
- **Issue:** `Board.ordered` returns rows across all accounts. The new `acme_one` fixture (name "Acme Features") sorted alphabetically before the test-created "Alpha", flipping `ordered.first.name` from "Alpha" to "Acme Features".
- **Fix:** Replaced `Board.ordered` with `accounts(:feedbackbin).boards.ordered`. This matches real-world usage (Board queries always run inside a tenant) and prevents future fixture additions from breaking the assertion.
- **Files modified:** `test/models/board_test.rb`
- **Verification:** Full suite green (958 runs, 0 failures).
- **Committed in:** `5560096` (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (test regression caused by fixture additions)
**Impact on plan:** No scope creep. The fix tightens the test to mirror production's tenant-scoped query pattern.

## Issues Encountered
- One full-suite regression caught and fixed (see Deviations above). All 7 new isolation tests pass on first run because the `belongs_to :account, default: -> { Current.account }` scoping was already correct; this plan simply locks the behavior under test.

## User Setup Required
None.

## Next Phase Readiness
- 3-account fixture pattern is in place — plan 01-05 (seeds) can target `feedbackbin`, `acme`, and `cleanstate` directly.
- Isolation guarantees are now under test, so future model changes that accidentally remove scoping defaults will be caught immediately.

---
*Phase: 01-foundations-safety-net*
*Completed: 2026-04-28*
