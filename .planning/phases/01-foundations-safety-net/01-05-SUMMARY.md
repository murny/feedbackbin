---
phase: 01-foundations-safety-net
plan: 05
subsystem: database
tags: [rails, seeds, development, performance, fixtures, fizzy-port]

requires:
  - phase: 01-02
    provides: account_cancellations migration so dev DB schema includes the new table before db:seed:replant
  - phase: 01-03
    provides: 3-account fixture pattern (feedbackbin, acme, cleanstate) that this plan mirrors at runtime
provides:
  - 3-tenant seed orchestration (feedbackbin bulk, acme secondary, cleanstate empty)
  - Power-law engagement distribution (votes 0/1-4/5-15/20-50, comments 0/1-3/5-10)
  - 90-day spread of created_at via ActiveSupport::Testing::TimeHelpers travel/travel_back
  - Synthetic 50-user voter pool so the 20-50 vote tier can actually materialize
affects: [02-roadmap-polish, 02-trending-feed, future N+1-fix phases]

tech-stack:
  added: []
  patterns:
    - "Top-level TimeHelpers include in db/seeds.rb so travel/travel_back are available inside required tenant seed files"
    - "Synthetic voter pool to break the unique-per-voter ceiling for power-law vote distribution"

key-files:
  created:
    - db/seeds/acme.rb
  modified:
    - db/seeds.rb
    - db/seeds/feedbackbin.rb
    - app/views/ideas/index.html.erb

key-decisions:
  - "Added a 50-user synthetic voter pool (voter1..voter50@volume.example.com) because the plan's 4-author pool collides with the unique (voter, voteable) Vote constraint, capping any idea at 4 votes"
  - "Treated the per-idea N+1 surfaced on the ideas index as out-of-scope (Pitfall 7 documented this as later phase work)"
  - "Bypassed the ar_internal_metadata environment guard with DISABLE_DATABASE_ENVIRONMENT_CHECK=1 because the dev DB had been re-stamped by an earlier test-env migration"

patterns-established:
  - "Volume-loop seed pattern: travel_back -> travel(-rand(1..N).days) wrap around create_idea + upvote + comment so all timestamps move together"
  - "Tenant seed file = create_tenant + seed_default_statuses + find_or_create_user + login_as + hand-crafted boards/ideas (acme is the minimal reference)"

requirements-completed: [FOUND-05]

duration: ~45min
completed: 2026-04-29
---

# Phase 01-05: Seed Data Expansion Summary

**3-tenant dev seed (175 + 3 + 0 ideas) with 90-day spread and power-law engagement that exposes the ideas-index N+1 for Phase 2+ to fix.**

## Performance

- **Duration:** ~45 min (sequential inline execution + manual checkpoint verification)
- **Completed:** 2026-04-29
- **Tasks:** 4 (3 auto + 1 human-verify checkpoint)
- **Files modified:** 4 (3 seed files + 1 view fix uncovered by the seed)

## Accomplishments
- **feedbackbin** account: 175 ideas (5 hand-crafted + 170 volume) spread across 89 days
- **acme** account: 3 ideas across 2 boards with one comment + 3 votes — small enough to read at a glance, big enough to prove cross-tenant isolation visually
- **cleanstate** account: 0 ideas (empty-state design surface for Phase 2 COMP-01)
- Power-law vote distribution materialized: max 33 votes, mean 3.96, 65 ideas at zero, 7 ideas with 20+ votes
- Power-law comment distribution: max 10 comments per idea, mean 1.54, 97 ideas at zero
- Seed runtime ~10s for feedbackbin (well under the 60s/120s caps from Pitfall 4)
- Surfaced an unrelated `pagy` typo in `app/views/ideas/index.html.erb` once the index crossed the pagination threshold, fixed in the same plan

## Task Commits

1. **Task 1: Extend seed DSL with TimeHelpers and third tenant** - `148fce1` (feat)
2. **Task 2: Create db/seeds/acme.rb secondary tenant** - `052c457` (feat)
3. **Task 3: Expand db/seeds/feedbackbin.rb with 170-idea power-law volume loop** - `6647e46` (feat)
4. **(Deviation): Fix pagy local in ideas index** - `7f2465f` (fix)
5. **Task 4: Visual confirmation of seed data performance** - approved by user (no commit; manual verification)

## Files Created/Modified
- `db/seeds.rb` - top-level TimeHelpers include + third `seed_account("acme")` orchestration call
- `db/seeds/acme.rb` - new secondary-tenant seed (Alice + Bob, 2 boards, 3 ideas)
- `db/seeds/feedbackbin.rb` - appended 170-idea volume loop with travel/travel_back, 30 template titles, power-law vote/comment cases
- `app/views/ideas/index.html.erb` - fixed bare `pagy.info_tag` / `pagy.series_nav` to use the `@pagy` instance variable (the conditional was already correct)

## Decisions Made
- **Synthetic voter pool (50 users, voter1..voter50@volume.example.com).** The plan literally specified `vote_count.times { upvote(idea, voter: authors.sample) }` with `authors = [shane, jane, john, eric]`. But `Vote` enforces uniqueness on (voter, voteable), so only 4 distinct upvotes can ever stick per idea. The plan's success criterion explicitly required "some ideas have 20+ votes". Without more voters, that target is structurally unreachable. Adding the synthetic pool resolves the contradiction without changing idea or comment authorship (those still sample from `authors`).
- **Pre-existing N+1 not fixed.** The ideas index renders in 296ms with 103 queries for 20 ideas (4 N+1 queries per idea: `Vote Exists?`, `ActionText::RichText Load`, `Comment Pluck`, `User Load`). Plan 01-05's `<how-to-verify>` step 5 explicitly framed this as *"seed volume exposing N+1 is the goal; fixing it is later scope (Pitfall 7)"*. Confirmed via user verification; will be addressed in a Phase 2+ optimization phase.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Plan Internal Contradiction] Added synthetic voter pool to make 20-50 vote tier reachable**
- **Found during:** Task 3 verification (post-seed distribution check showed `max=4 mean=1.62 zeros=63`, no ideas with 20+ votes)
- **Issue:** Plan task code uses 4 named authors as voters, but Vote model enforces unique (voter, voteable). Plan success criterion requires "some ideas have 20+ votes". These two are incompatible.
- **Fix:** Appended `voters = authors + 50.times.map { |n| find_or_create_user("Volume Voter #{n+1}", "voter#{n+1}@volume.example.com") }` and used `voters.sample` for upvotes only. Idea/comment authorship still sample from `authors`.
- **Files modified:** `db/seeds/feedbackbin.rb`
- **Verification:** Re-ran `db:seed:replant`. New distribution: `max=33 mean=3.96 zeros=65`, with 7 ideas at 20+ votes.
- **Committed in:** `6647e46` (Task 3 commit)

**2. [Rule 2 - Verification Blocker] Fixed pagy local in ideas index template**
- **Found during:** Task 4 (user reported `undefined local variable or method 'pagy'` on the ideas index)
- **Issue:** `app/views/ideas/index.html.erb:117-118` used bare `pagy.info_tag` / `pagy.series_nav` but the file is a top-level template (not a partial that receives `pagy` as a local). The conditional on line 115 already used `@pagy` correctly. Pre-existing bug, only triggered now because the new seed volume crossed Pagy's pagination threshold.
- **Fix:** Replaced bare `pagy` with `@pagy` on lines 117-118 to match line 115.
- **Files modified:** `app/views/ideas/index.html.erb`
- **Verification:** Page now loads (200 OK) for the user.
- **Committed in:** `7f2465f`

**3. [Rule 3 - Environment Snag] Bypassed ar_internal_metadata env check**
- **Found during:** Task 3 verification (db:seed:replant aborted with `ActiveRecord::EnvironmentMismatchError`)
- **Issue:** An earlier `bin/rails db:migrate RAILS_ENV=test` run (during 01-02 cherry-pick verification) wrote a `test` value into `ar_internal_metadata` of the development sqlite file, blocking subsequent dev seeds.
- **Fix:** Used `DISABLE_DATABASE_ENVIRONMENT_CHECK=1` for the dev seed run. Did not modify env-check behavior, just opted out of it for this one run.
- **Files modified:** none
- **Verification:** Seed completed cleanly in ~10s.
- **Committed in:** N/A (runtime flag, not a code change)

---

**Total deviations:** 3 auto-fixed (1 plan internal contradiction, 1 pre-existing bug uncovered, 1 environment snag).
**Impact on plan:** All deviations were necessary to satisfy the plan's stated success criteria or unblock verification. No scope creep beyond what the plan's checkpoint surfaced.

## Issues Encountered
- Per-idea N+1 on the ideas index (documented above). Not a Phase 1 issue — Phase 2+ work.
- Latent identical pagy bug remains in `app/views/changelogs/index.html.erb:38-39`. Not blocking today (seed doesn't create paginated changelogs); flagged to user, no fix applied.

## User Setup Required
None — seeds run via `bin/rails db:seed:replant` in the development environment. (One-time `DISABLE_DATABASE_ENVIRONMENT_CHECK=1` was needed to clear the test-env metadata stamp; future runs from a clean state won't need it.)

## Next Phase Readiness
- 3-tenant seed gives Phase 2 (UI polish) and any future trending/roadmap phases a realistic dataset to render against.
- N+1 on ideas index is the obvious next perf fix once Phase 2 starts.
- Wave 3 (plan 01-06 smoke tests) can proceed — its system tests don't depend on dev-DB state.

---
*Phase: 01-foundations-safety-net*
*Completed: 2026-04-29*
