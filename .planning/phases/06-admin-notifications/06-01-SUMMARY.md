---
phase: 06-admin-notifications
plan: 01
subsystem: notifications
tags: [notifications, watches, vote, auto-watch, callbacks]

requires:
  - phase: 04
    provides: Idea creator auto-watch (subscribe_creator) + Idea::Watchable#watch_by idempotent helper
  - phase: 04
    provides: Comment author auto-watch (watch_idea_by_creator)
provides:
  - Vote#after_create_commit :watch_idea_by_voter callback (D-06)
  - Vote auto-watch tests (Idea-only, Comment-exclusion, system-exclusion, bot-exclusion)
affects: [06-02-comment-mailer, 06-05-user-watches-management]

tech-stack:
  added: []
  patterns:
    - "Vote-as-watcher pattern: voting on an Idea implies subscription to that Idea's watcher set"
    - "Polymorphic-aware after_create_commit: guard predicate filters voteable_type before invoking watchable helper"

key-files:
  created: []
  modified:
    - app/models/vote.rb
    - test/models/vote_test.rb

key-decisions:
  - "Callback declared on Vote (not Voteable concern) to mirror Comment's pattern at app/models/comment.rb:27 and avoid leaking idea-specific logic into polymorphic concern"
  - "Belt-and-braces system/bot guard at write site even though Idea::Watchable#watchers filters them downstream — keeps watches table clean"
  - "Delegated to idempotent Idea::Watchable#watch_by (first_or_create.update!) — no custom upsert, no ActiveRecord rescue needed"

patterns-established:
  - "Vote auto-watch: real-user Idea votes create Watch row in same transaction tail"
  - "voteable_type == \"Idea\" guard pattern for polymorphic Vote callbacks (RESEARCH Pitfall 1)"

requirements-completed: [ADMN-02]

duration: 6min
completed: 2026-06-17
---

# Phase 06 Plan 01: Vote Auto-Watch (D-06) Summary

**Voting on an Idea by a real user now auto-creates a Watch row via `Vote#after_create_commit`, closing the Vote leg of the three auto-watch triggers and feeding plan 06-02's comment mailer + plan 06-05's `/user_settings/watches` UI.**

## Performance

- **Duration:** ~6 min
- **Started:** 2026-06-17T13:57:00Z
- **Completed:** 2026-06-17T14:03:22Z
- **Tasks:** 3 (Task 3 was verification-only, no commit)
- **Files modified:** 2

## Accomplishments

- Added `Vote#after_create_commit :watch_idea_by_voter` gated on `idea_vote_by_real_user?`
- `voteable_type == "Idea"` guard prevents Watch rows being created against polymorphic Comment voteables (Watch belongs_to :idea)
- `voter.system?` / `voter.bot?` guards keep automation noise out of the watches table
- 4 new distinct unit tests in `test/models/vote_test.rb` (no `each` loops per project memory "No loop tests")
- Verified Phase 4 & 5 regression: Idea creator auto-watch and Comment author auto-watch unchanged
- Full `bin/rails test` (1115 runs, 2960 assertions, 0 failures)

## Task Commits

Each task was committed atomically following the plan-level TDD gate sequence:

1. **Task 2 (RED): Extend test/models/vote_test.rb with auto-watch unit tests** — `b814ad6` (test)
2. **Task 1 (GREEN): Add Vote#after_create_commit auto-watch callback** — `d6f2acf` (feat)
3. **Task 3: Regression verification (existing Idea + Comment auto-watch tests pass)** — verification-only, no commit (no source changes)

_Task order swapped vs. plan numbering to honor TDD RED-before-GREEN gate ordering. Both files (`app/models/vote.rb`, `test/models/vote_test.rb`) tagged `tdd="true"` in the plan; the plan-level `type: tdd` mandates test commit precedes feat commit._

## Files Created/Modified

- `app/models/vote.rb` — Added `after_create_commit :watch_idea_by_voter, if: :idea_vote_by_real_user?` plus two private methods (`idea_vote_by_real_user?` predicate + `watch_idea_by_voter` callback body delegating to `voteable.watch_by(voter)`)
- `test/models/vote_test.rb` — Added 4 new tests covering happy path (Idea vote by real user) + 3 exclusions (Comment voteable, system voter, bot voter)

## Decisions Made

- **Callback on Vote, not Voteable concern:** Mirrors `Comment#watch_idea_by_creator` (app/models/comment.rb:27,74-76). Keeping the polymorphic concern free of idea-specific logic; `Voteable` stays applicable to both Idea and Comment without leaking Watch concerns.
- **Belt-and-braces system/bot guard:** Even though `Idea::Watchable#watchers` already filters `role: [:system, :bot]` at the read side (app/models/idea/watchable.rb:8), we guard at the write side too. Cheaper than retroactive cleanup if the read-side filter ever changes.
- **No rescue around `voteable.watch_by(voter)`:** `Idea::Watchable#watch_by` uses `where(user:).first_or_create.update!(watching: true)` (app/models/idea/watchable.rb:21-23) which is idempotent — re-votes after destroy+recreate don't raise or duplicate.

## Deviations from Plan

None — plan executed exactly as written. The task ordering followed TDD gate sequencing (test commit before feat commit) which the plan's `tdd="true"` flags explicitly required.

## Issues Encountered

None.

## TDD Gate Compliance

- **RED gate:** Commit `b814ad6` is a `test(06-01): ...` commit. Verified the new `auto-watches idea when user votes on an idea` test failed before any implementation (`Expected nil to be truthy`). The three exclusion tests (Comment, system, bot) passed trivially in the RED phase because no callback existed; they continued to pass after GREEN because the guards explicitly exclude those code paths.
- **GREEN gate:** Commit `d6f2acf` is a `feat(06-01): ...` commit. All 10 tests in `vote_test.rb` pass, plus full `bin/rails test` (1115 runs).
- **REFACTOR gate:** Not required; implementation is minimal (3 lines in private methods + 1 callback declaration).

## Threat Flags

None — implementation matches the threat register dispositions (T-06-04 mitigated downstream by mailer recipients filter; T-06-VT-01 and T-06-VT-02 both mitigated by the guards added in this plan).

## User Setup Required

None — purely internal model behavior.

## Next Phase Readiness

- Plan 06-02 (comment mailer) can rely on voters appearing in `Idea#watchers` for any Idea they've voted on by a real user.
- Plan 06-05 (`/user_settings/watches` UI) will surface voted-on Ideas in the user's subscription list because the auto-watch row exists in the same `watches` table the UI lists from.
- No blockers.

## Self-Check: PASSED

- File `app/models/vote.rb` present with `after_create_commit :watch_idea_by_voter` callback (1 match).
- File `test/models/vote_test.rb` present with 4 new test names matching the plan's acceptance criteria.
- Commit `b814ad6` (test) and `d6f2acf` (feat) both present in `git log`.
- `app/models/concerns/voteable.rb` unchanged (`git diff` empty).
- `bin/rails test` full suite passes (1115 runs, 0 failures).
- `bin/rubocop app/models/vote.rb test/models/vote_test.rb` clean (no offenses).

---
*Phase: 06-admin-notifications*
*Completed: 2026-06-17*
