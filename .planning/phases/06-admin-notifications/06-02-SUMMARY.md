---
phase: 06-admin-notifications
plan: 02
subsystem: notifications
tags: [notifications, mailers, comment, internal-comment-filter, actiontext, super-tap, deliver_later]

requires:
  - phase: 03-feedback-polish
    provides: Notifier::CommentEventNotifier#recipients with internal-comment staff-only filter (T-06-04 mitigation source of truth)
  - phase: 04-roadmap-changelog
    provides: IdeaStatusChangeMailer + Notifier::IdeaEventNotifier super.tap dispatch pattern (verbatim analog)
provides:
  - IdeaCommentMailer with new_comment action, HTML + text views
  - Notifier::CommentEventNotifier#notify override dispatching IdeaCommentMailer.deliver_later per recipient on comment_created
  - i18n keys idea_comment_mailer.new_comment.{subject,heading,lead,cta}
affects: [06-03, 06-04, 06-05, 06-06]

tech-stack:
  added: []
  patterns:
    - "super.tap mailer dispatch pattern in EventNotifier subclasses (carried from Phase 4 IdeaEventNotifier)"
    - "Mailer URL includes account slug via ApplicationMailer#default_url_options"
    - "Internal-comment safety: dispatch loop inherits recipients filter; no duplicated comment.internal? check in the tap block"

key-files:
  created:
    - app/mailers/idea_comment_mailer.rb
    - app/views/idea_comment_mailer/new_comment.html.erb
    - app/views/idea_comment_mailer/new_comment.text.erb
    - test/mailers/idea_comment_mailer_test.rb
  modified:
    - app/models/notifier/comment_event_notifier.rb
    - test/models/notifier/comment_event_notifier_test.rb
    - config/locales/en.yml

key-decisions:
  - "Dispatch loop iterates parent-built notifications; internal-comment filter lives only in Notifier::CommentEventNotifier#recipients (single source of truth, T-06-04 mitigation)"
  - "Mailer uses lazy i18n inside the action (`t('.subject', ...)`); subject lookup safe in action methods (RESEARCH Pitfall 5)"
  - "CTA links to idea_url with anchor: 'comment_#{@comment.id}' so the recipient lands at the new comment"

patterns-established:
  - "EventNotifier subclasses opt into mail dispatch via super.tap, guarded by an action-name string check; no parent-class change required"

requirements-completed: [ADMN-03]

duration: ~12 min
completed: 2026-06-17
---

# Phase 06 Plan 02: Comment Notification Mailer Summary

**IdeaCommentMailer + Notifier::CommentEventNotifier super.tap dispatch enqueues one IdeaCommentMailer.new_comment email per non-commenter watcher; internal-comment staff-only filter inherits from the existing recipients scope without duplication.**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-06-17 (worktree wave 1)
- **Completed:** 2026-06-17
- **Tasks:** 2 (both TDD: RED + GREEN per task)
- **Files modified:** 7 (4 created, 3 modified)

## Accomplishments
- IdeaCommentMailer.new_comment delivers HTML + text email with the comment body (via `@comment.body.to_plain_text`), a CTA to the idea URL anchored on the new comment, and an i18n-driven subject.
- Notifier::CommentEventNotifier#notify wraps `super.tap` and dispatches `IdeaCommentMailer.with(comment:, recipient:).new_comment.deliver_later` per notification, guarded by `source.action == "comment_created"`.
- Internal-comment T-06-04 mitigation preserved: the dispatch loop iterates pre-filtered notifications, so non-staff watchers receive zero emails (asserted by `assert_enqueued_emails 0` extension to existing internal-comment test).
- Phase 4 IdeaEventNotifier mailer behavior untouched (regression suite green).

## Task Commits

Each TDD task split into RED + GREEN commits:

1. **Task 1 RED — failing mailer test** — `db09ec9` (test)
2. **Task 1 GREEN — IdeaCommentMailer + views + i18n** — `d3b2cf4` (feat)
3. **Task 2 RED — failing enqueue assertions** — `1453305` (test)
4. **Task 2 GREEN — super.tap dispatch in Notifier::CommentEventNotifier** — `7390956` (feat)

## Files Created/Modified
- `app/mailers/idea_comment_mailer.rb` (created) — ApplicationMailer subclass with single `new_comment` action; reads `:comment` + `:recipient` from mailer params.
- `app/views/idea_comment_mailer/new_comment.html.erb` (created) — Heading, lead, `<blockquote>` quoting the plain-text comment body, and an Elements::ButtonComponent CTA linking to `idea_url(@idea, anchor: "comment_#{@comment.id}")`.
- `app/views/idea_comment_mailer/new_comment.text.erb` (created) — Plain-text mirror of the HTML view.
- `test/mailers/idea_comment_mailer_test.rb` (created) — 4 distinct tests (subject, recipient, idea-link with `script_name: Current.account.slug`, comment body included).
- `app/models/notifier/comment_event_notifier.rb` (modified) — Added `notify` override above the existing `private` keyword; existing `recipients` private method (lines 24-32 pre-edit) untouched.
- `test/models/notifier/comment_event_notifier_test.rb` (modified) — Included `ActionMailer::TestHelper`; extended the internal-comment test to assert `assert_enqueued_emails 0`; added a new test asserting one enqueue per watcher (excluding commenter).
- `config/locales/en.yml` (modified) — Added `idea_comment_mailer.new_comment.{cta,heading,lead,subject}` keys (sibling of `idea_status_change_mailer`).

## Decisions Made
- The mailer dispatch is the only consumer that needs an `:owner/:admin` filter; the existing recipients scope handles it, so the dispatch loop is intentionally filter-free. This matches the T-06-04 mitigation in the plan's threat model.
- Subject uses lazy i18n (`t(".subject", ...)`) — safe because the lookup runs in the mailer action (not a private before_action), per RESEARCH Pitfall 5.
- `idea_url` (not `idea_path`) is used so `default_url_options.script_name = Current.account.slug` injection still produces the account-prefixed absolute URL in mailers.
- The CTA anchor (`comment_#{@comment.id}`) is added now because it's free; the unwatch footer (D-10) explicitly stays out of scope — plan 06-04 owns it.

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required
None — no external service configuration required.

## Verification

- `bin/rails test test/mailers/idea_comment_mailer_test.rb test/models/notifier/comment_event_notifier_test.rb test/models/notifier/idea_event_notifier_test.rb` → 27 runs, 76 assertions, 0 failures.
- `bin/rubocop app/mailers/idea_comment_mailer.rb app/models/notifier/comment_event_notifier.rb test/mailers/idea_comment_mailer_test.rb` → no offenses.
- `bin/i18n-tasks health` → no missing or unused keys.
- `bin/erb_lint app/views/idea_comment_mailer/` → no errors.

## Next Phase Readiness
- Plan 06-04 can append the unwatch + manage footer to both `idea_comment_mailer/new_comment.{html,text}.erb` and `idea_status_change_mailer/status_changed.{html,text}.erb`. Both views end with a final `<p>` so the footer can be appended below without restructuring.
- Plan 06-05 (notification preferences) can branch on `comment_created` action when checking user opt-out before the deliver_later call (no current branch — `should_notify?` only filters system users).

## Self-Check: PASSED

- IdeaCommentMailer class file present at `app/mailers/idea_comment_mailer.rb` (verified by grep).
- HTML view present with `@comment.body.to_plain_text` and `idea_url(@idea` (verified by grep).
- Text view present with `@comment.body.to_plain_text` and `idea_url` (verified by grep).
- 4 mailer tests; `bin/rails test` exits 0.
- Notifier override added (`def notify`, `super.tap`, `IdeaCommentMailer`, `deliver_later`, `comment_created`) without modifying the `recipients` private method (verified by `git diff` of the recipients block — no changes).
- 2 `assert_enqueued_emails` matches in notifier test.
- All commits present in git log: db09ec9, d3b2cf4, 1453305, 7390956.

---
*Phase: 06-admin-notifications*
*Plan: 02*
*Completed: 2026-06-17*
